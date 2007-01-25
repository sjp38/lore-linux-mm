Message-ID: <45B842E6.5040008@redhat.com>
Date: Thu, 25 Jan 2007 00:40:54 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] Limit the size of the pagecache
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>	<20070124121318.6874f003.kamezawa.hiroyu@jp.fujitsu.com>	<Pine.LNX.4.64.0701232028520.6820@schroedinger.engr.sgi.com>	<20070124141510.7775829c.kamezawa.hiroyu@jp.fujitsu.com>	<20070125093259.74f76144.kamezawa.hiroyu@jp.fujitsu.com>	<Pine.LNX.4.64.0701241841000.12325@schroedinger.engr.sgi.com>	<20070125121254.a2e91875.kamezawa.hiroyu@jp.fujitsu.com>	<45B831DF.7080506@redhat.com> <20070125141944.67347aeb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070125141944.67347aeb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: clameter@sgi.com, aubreylee@gmail.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, rgetz@blackfin.uclinux.org, Michael.Hennerich@analog.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 24 Jan 2007 23:28:15 -0500
> Rik van Riel <riel@redhat.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>
>>> FYI:
>>> Because some customers are migrated from mainframes, they want to control
>>> almost all features in OS, IOW, designing memory usages.
>> Don't you mean:
>>
>> "Because some customers are migrating from mainframes, they are
>>   used to needing to control all features in OS" ? :)
>>
> Ah yes ;)
> I always says Linux is different from mainframes.

It's not just about Linux.

Applications behave differently too from the way they were 15
years ago.

Some databases, eg. sleepycat's db, map the whole database in
memory.  Other databases, like MySQL and postgresql, rely on
the kernel's page cache to cache the most frequently accessed
data.

To make matters more interesting, memory sizes have increased
by a factor 1000, but disk seek times have only gotten 10 times
faster.  This means that simplistic memory management algorithms
can hurt performance a lot more than they could back then.

In short, I am not convinced that any of the simple tunable knobs
from the "good old days" will do much to actually help people
with modern workloads on modern computers.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
