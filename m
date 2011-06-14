Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 013476B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 08:33:10 -0400 (EDT)
Received: by pvc12 with SMTP id 12so3246867pvc.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 05:33:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110614101047.GG6371@cmpxchg.org>
References: <BANLkTinptn4-+u+jgOr2vf2iuiVS3mmYXA@mail.gmail.com>
 <BANLkTimDtpVeLYisfon7g_=H80D0XXgkGQ@mail.gmail.com> <BANLkTim8ngH8ASTk9js-G9DxySWVb7VL3A@mail.gmail.com>
 <BANLkTim67zDojKPezhyAM=rzt-Mop1SFeg@mail.gmail.com> <20110614101047.GG6371@cmpxchg.org>
From: Andrew Lutomirski <luto@mit.edu>
Date: Tue, 14 Jun 2011 08:32:48 -0400
Message-ID: <BANLkTimJVvGaEZBm1+tRvkNYoCv4p0rk7Q@mail.gmail.com>
Subject: Re: Easy portable testcase! (Re: Kernel falls apart under light
 memory pressure (i.e. linking vmlinux))
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, mgorman@suse.de, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Tue, Jun 14, 2011 at 6:10 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Sun, May 29, 2011 at 08:28:46PM -0400, Andrew Lutomirski wrote:
>> On Sun, May 29, 2011 at 2:28 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
>> >>
>> >> It works only if the zone meets high watermark. If allocation is
>> >> faster than reclaim(ie, it's true for slow swap device), the zone
>> >> would remain congested.
>> >> It means swapout would block.
>> >> As we see the OOM log, we can know that DMA32 zone can't meet high watermark.
>> >>
>> >> Does my guessing make sense?
>> >
>> > Hi Andrew.
>> > I got failed your scenario in my machine so could you be willing to
>> > test this patch for proving my above scenario?
>> > The patch is just revert patch of 0e093d99[do not sleep on the
>> > congestion queue...] for 2.6.38.6.
>> > I would like to test it for proving my above zone congestion scenario.
>> >
>> > I did it based on 2.6.38.6 for your easy apply so you must apply it
>> > cleanly on vanilla v2.6.38.6.
>> > And you have to add !pgdat_balanced and shrink_slab patch.
>>
>> No, because my laptop just decided that it doesn't like to turn on. :(
>>
>> I'll test it on my VM on Tuesday and (fingers crossed) on my repaired
>> laptop next weekend.
>
> Any updates on this?
>

Sorry, got distracted by writing my thesis.

This patch (Revert "writeback: do not sleep on the congestion queue if
there are no congested BDIs or if significant congestion is not being
encountered in the current zone") does not fix the problem; if
anything it triggers more easily with the patch (at least in KVM).

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
