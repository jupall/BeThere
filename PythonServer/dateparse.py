import datetime as dt
import iso8601
from random import choice

class Slot():
    def __init__(self, start, end):
        if isinstance(start, str):
            self.start = iso8601.parse_date(start[0:19])
            self.end = iso8601.parse_date(end[0:19])
        else:
            self.start = start
            self.end = end


    '''def conflict(self, other):
        if isinstance(other, Slot):
            if other.start > self.start and other.end < self.end\
                or self.start>other.start and self.end< other.end:
                return True
        return False'''

    def __str__(self):
        return "start:{}, end:{}".format(self.start, self.end)


class SlotCount(Slot):
    def __init__(self, start, end, count=0, members=[]):
        super().__init__(start, end)
        self.count = count
        self.members = members

    def check(self, person):
        if person.conflict(self):
            self.count += 1
            self.members.append(person.name)



class Person():

    def __init__(self, dates = [], name="", tel=""):
        self.name = name
        self.tel = tel
        if len(dates)==0:
            self.dates = dates
        else:
            self.dates = []
            for el in dates:
                self.dates.append(Slot(el['start'], el['end']))

    def conflict(self, slot):
        ans = False
        for s in self.dates:
            if (s.start<=slot.start and s.end>=slot.end):
                return True
        return False

class Grid():

    def __init__(self, start, end, timestep=30):
        delta = dt.timedelta(minutes=timestep)
        if isinstance(start, str):
            start = iso8601.parse_date(start)
            end = iso8601.parse_date(end)
        beg = start
        self.ls = []
        while beg < end:
            self.ls.append(SlotCount(beg, beg+delta))
            beg += delta

        self.best = None
        self.delta = delta

    def update(self, PersLs):
        for p in PersLs:
            for slot in self.ls:
                slot.check(p)


    def getBest(self, periods=4):
        bestStart = [self.ls[0].start]
        bestCount = self.ls[0].count
        start = None
        i=0
        length = 0
        for i in range(0, len(self.ls)-periods):
            score = sum([self.ls[j].count for j in range(i, i+periods)])
            if score > bestCount:
                bestStart = [self.ls[i].start]
                bestCount = score
            elif score == bestCount:
                bestStart.append(self.ls[i].start)
        return bestStart

    def getOnlyGood(self, periods=4):
        ans = []
        for i in range(0, len(self.ls)-periods):
            score = sum([self.ls[j].count for j in range(i, i+periods)])
            if score == periods:
                ans += [self.ls[i].start]
        return ans

    def choose(self, periods=4):
        bestStart = self.getBest(periods)
        ch = choice(bestStart)
        return ch.strftime("%B %d, %Y, %H:%M")

    def results(self, periods=4):
        bestStart = self.getBest(periods)
        if len(bestStart)==0:
            return None
        ans = []
        start = bestStart[0]
        end = start+self.delta
        for el in range(1, len(bestStart)):
            if end == bestStart[el]:
                end = bestStart[el] + self.delta
                if el+1 == len(bestStart):
                    ans.append(Slot(start, end))
            else:
                ans.append(Slot(start, end))
                start = bestStart[el]
                end = start+self.delta
        return ans

        

    
