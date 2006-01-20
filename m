Message-ID: <43D03C24.5080409@jp.fujitsu.com>
Date: Fri, 20 Jan 2006 10:25:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 0/5] Reducing fragmentation using zones
References: <20060119190846.16909.14133.sendpatchset@skynet.csn.ul.ie> <43CFE77B.3090708@austin.ibm.com> <43D02B3E.5030603@jp.fujitsu.com> <Pine.LNX.4.58.0601200102040.15823@skynet>
In-Reply-To: <Pine.LNX.4.58.0601200102040.15823@skynet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Joel Schopp <jschopp@austin.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
>> Joel Schopp wrote:
>>>> Benchmark comparison between -mm+NoOOM tree and with the new zones
>>> I know you had also previously posted a very simplified version of your real
>>> fragmentation avoidance patches.  I was curious if you could repost those
>>> with the other benchmarks for a 3 way comparison.  The simplified version
>>> got rid of a lot of the complexity people were complaining about and in my
>>> mind still seems like preferable direction.
>>>
>> I agree. I think you should try with simplified version again.
>> Then, we can discuss.
>>
> 
> Results from list-based have been posted. The actual patches will be
> posted tomorrow (in local time, that is in about 12 hours time)
> 
Thank you.


>>  I don't like using bitmap which I removed (T.T
>>
>>> Zone based approaches are runtime inflexible and require boot time tuning by
>>> the sysadmin.  There are lots of workloads that "reasonable" defaults for a
>>> zone based approach would cause the system to regress terribly.
>>>
>> IMHO, I don't like automatic runtime tuning, you say 'flexible' here.
>> I think flexibility allows 2^(MAX_ORDER - 1) size fragmentaion.
>> When SECTION_SIZE > MAX_ORDER, this is terrible.
>>
> 
> In an ideal world, we would have both. Zone-based would give guarantees on
> the availability of reclaimed pages and list-based would give best-effort
> everywhere.
> 
>> I love certainty that sysadmin can grap his system at boot-time.
> 
> It requires careful tuning. For suddenly different workloads, things may
> go wrong. As with everything else, testing is required from workloads
> defined by multiple people.
> 
Yes, we need more test.


>> And, for people who want to remove range of memory, list-based approach will
>> need some other hook and its flexibility is of no use.
>> (If list-based approach goes, I or someone will do.)
>>
> 
> Will do what?
> 
add kernelcore= boot option and so on :)
As you say, "In an ideal world, we would have both".

>> I know zone->zone_start_pfn can be removed very easily.
>> This means there is possiblity to reconfigure zone on demand and
>> zone-based approach can be a bit more fliexible.
>>
> 
> The obvious concern is that it is very easy to grow ZONE_NORMAL or
> ZONE_HIGHMEM into the ZONE_EASYRCLM zone but it is hard to do the opposite
> because you must be able to reclaim the pages at the end of the "awkward"
> zone.
Yes, this is weak point of ZONE_EASYRCLM.

By the way, please test this in list-based approach.
==
%ls -lR / (and some commands uses many slabs)
%do high ordet test
==

-- Kame.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
