Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B0EF690013A
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 11:34:00 -0400 (EDT)
Message-ID: <4E00B8E6.8050508@draigBrady.com>
Date: Tue, 21 Jun 2011 16:29:42 +0100
From: =?ISO-8859-15?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: sandy bridge kswapd0 livelock with pagecache
References: <4E0069FE.4000708@draigBrady.com> <20110621103920.GF9396@suse.de> <4E0076C7.4000809@draigBrady.com> <20110621113447.GG9396@suse.de> <4E008784.80107@draigBrady.com> <20110621143434.GI9396@suse.de>
In-Reply-To: <20110621143434.GI9396@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

On 21/06/11 15:34, Mel Gorman wrote:
> On Tue, Jun 21, 2011 at 12:59:00PM +0100, P?draig Brady wrote:
>> On 21/06/11 12:34, Mel Gorman wrote:
>>> On Tue, Jun 21, 2011 at 11:47:35AM +0100, P?draig Brady wrote:
>>>> On 21/06/11 11:39, Mel Gorman wrote:
>>>>> On Tue, Jun 21, 2011 at 10:53:02AM +0100, P?draig Brady wrote:
>>>>>> I tried the 2 patches here to no avail:
>>>>>> http://marc.info/?l=linux-mm&m=130503811704830&w=2
>>>>>>
>>>>>> I originally logged this at:
>>>>>> https://bugzilla.redhat.com/show_bug.cgi?id=712019
>>>>>>
>>>>>> I can compile up and quickly test any suggestions.
>>>>>>
>>>>>
>>>>> I recently looked through what kswapd does and there are a number
>>>>> of problem areas. Unfortunately, I haven't gotten around to doing
>>>>> anything about it yet or running the test cases to see if they are
>>>>> really problems. In your case, the following is a strong possibility
>>>>> though. This should be applied on top of the two patches merged from
>>>>> that thread.
>>>>>
>>>>> This is not tested in any way, based on 3.0-rc3
>>>>
>>>> This does not fix the issue here.
>>>>
>>>
>>> I made a silly mistake here.  When you mentioned two patches applied,
>>> I assumed you meant two patches that were finally merged from that
>>> discussion thread instead of looking at your linked mail. Now that I
>>> have checked, I think you applied the SLUB patches while the patches
>>> I was thinking of are;
>>>
>>> [afc7e326: mm: vmscan: correct use of pgdat_balanced in sleeping_prematurely]
>>> [f06590bd: mm: vmscan: correctly check if reclaimer should schedule during shrink_slab]
>>>
>>> The first one in particular has been reported by another user to fix
>>> hangs related to copying large files. I'm assuming you are testing
>>> against the Fedora kernel. As these patches were merged for 3.0-rc1, can
>>> you check if applying just these two patches to your kernel helps?
>>
>> These patches are already present in my 2.6.38.8-32.fc15.x86_64 kernel :(
>>
> 
> While doing a review of patches for unrelated reasons between 2.6.38
> and 3.0-rc3, I noted a few patches related to high CPU usage that may
> not have made it to the Fedora kernel.
> 
> * d527caf2 mm: compaction: prevent kswapd compacting memory to reduce CPU usage
> * 929bea7c vmscan: all_unreclaimable() use zone->all_unreclaimable as a name
> * afc7e326 mm: vmscan: correct use of pgdat_balanced in sleeping_prematurely
> * f06590bd mm: vmscan: correctly check if reclaimer should schedule during shrink_slab

Those were already applied, yes.

>   8afdcece mm: vmscan: kswapd should not free an excessive number of pages when balancing small zones
>   602605a4 mm: compaction: minimise the time IRQs are disabled while isolating free pages
>   b2eef8c0 mm: compaction: minimise the time IRQs are disabled while isolating pages for migration

The above had no effect.

cheers,
Padraig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
