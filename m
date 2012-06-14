Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id DBF016B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 20:51:53 -0400 (EDT)
Message-ID: <4FD935A4.3040207@kernel.org>
Date: Thu, 14 Jun 2012 09:51:48 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: clean up __count_immobile_pages
References: <1339380442-1137-1-git-send-email-minchan@kernel.org> <20120611144011.60fd76c8.akpm@linux-foundation.org> <4FD67E00.4040700@kernel.org> <20120613161921.e791d469.akpm@linux-foundation.org>
In-Reply-To: <20120613161921.e791d469.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Andrea Arcangeli <aarcange@redhat.com>

On 06/14/2012 08:19 AM, Andrew Morton wrote:

> On Tue, 12 Jun 2012 08:23:44 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
>> On 06/12/2012 06:40 AM, Andrew Morton wrote:
>>
>>> On Mon, 11 Jun 2012 11:07:22 +0900
>>> Minchan Kim <minchan@kernel.org> wrote:
>>>
>>>> __count_immobile_pages naming is rather awkward.
>>>> This patch clean up the function and add comment.
>>>
>>> This conflicts with
>>> mm-compaction-handle-incorrect-migrate_unmovable-type-pageblocks.patch
>>> and its fixes.
>>
> 
> It would be useful to Cc Bart when we're discussing his patch...
> 
>> I wanted to revert [1] and friends and merge again based on [2] and this patch.
>> Because [1] has still bug I explained in [2]. If it is merged without [2], it simply can
>> spread bug from one place(memory hotplug) to two place(memory hotplug and compaction).
>>
>> We discussed real effectiveness of [1] because the patch is rather complicated than
>> expectation. I don't want to add unnecessary maintain cost if it doesn't have proved benefit.
>>
>> KOSAKI and me : doesn't want to merge without proving (https://lkml.org/lkml/2012/6/5/3)
>> Mel: Pass the decision to CMA guys (https://lkml.org/lkml/2012/6/11/242)
>> Rik: want to test it based on THP alloc ratio (https://lkml.org/lkml/2012/6/11/293)
>>
>> I guess anyone has no sure for needing it, at least.
>>
>> Even, [1] added new vmstat "compact_rescued_unmovable_blocks". 
>> Why I firstly suggest is just for the proving the effectiveness easily and wanted to
>> revert the vmstat later before merging mainline if we prove it.
>> (But it seems that KOSAKI doesn't like it - https://lkml.org/lkml/2012/6/5/282)
>> But now Bartlomiej want to maintain it permanently in vmstat.
>> IMHO, it's not a good idea.
>> Anyway, adding new vmstat part should be careful and get a agreement from mm guys.
>>
>> [1] mm-compaction-handle-incorrect-migrate_unmovable-type-pageblocks.patch
>> [2] [PATCH] mm: do not use page_count without a page pin
> 
> Right now I'm inclined to drop
> mm-compaction-handle-incorrect-migrate_unmovable-type-pageblocks.patch
> then sit back and let you guys hash out a new patch(set).


Bartlomiej already agreed resending based on [2].

Quote from last discussion with Bart
<<
On Monday 11 June 2012 03:26:49 Minchan Kim wrote:
> Hi Bartlomiej,
> 
> On 06/08/2012 05:46 PM, Bartlomiej Zolnierkiewicz wrote:
> 
> > 
> > Hi,
> > 
> > This version is much simpler as it just uses __count_immobile_pages()
> > instead of using its own open coded version and it integrates changes
> 
> 
> That's a good idea. I don't have noticed that function is there.
> When I look at the function, it has a problem, too.
> Please, look at this.
> 
> https://lkml.org/lkml/2012/6/10/180
> 
> If reviewer is okay that patch, I would like to resend your patch based on that. 

Ok, I would later merge all changes into v11 and rebase on top of your patch."
>>

Remain thing is that I should resend [2] with Andrea's two suggestion.

(1) add comment THP tail page skip
(2) find unmovable page improvement on THP page

(1) is trivial so I am happy to add in my patch but (2) is going on discuss so didn't complete now
And (2) is optimization patch, not critical BUG fix so I will make it as another patch.

So, I will resend [2] and this patch mm: clean up __count_immobile_pages as soon as possible.
I hope Bartlomiej resend his patch based on them.

Thanks, Andrew.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
