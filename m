Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 690166B005D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 02:26:20 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1041814bkc.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 23:26:18 -0800 (PST)
Message-ID: <50BC5419.6020903@googlemail.com>
Date: Mon, 03 Dec 2012 07:26:17 +0000
From: Chris Clayton <chris2553@googlemail.com>
MIME-Version: 1.0
Subject: Re: [RFT PATCH v2 4/5] mm: provide more accurate estimation of pages
 occupied by memmap
References: <20121120111942.c9596d3f.akpm@linux-foundation.org> <1353510586-6393-1-git-send-email-jiang.liu@huawei.com> <20121128155221.df369ce4.akpm@linux-foundation.org> <50B73E56.4050603@googlemail.com> <50BBB21D.3070005@googlemail.com>
In-Reply-To: <50BBB21D.3070005@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <liuj97@gmail.com>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/02/12 19:55, Chris Clayton wrote:
>
>
> On 11/29/12 10:52, Chris Clayton wrote:
>> On 11/28/12 23:52, Andrew Morton wrote:
>>> On Wed, 21 Nov 2012 23:09:46 +0800
>>> Jiang Liu <liuj97@gmail.com> wrote:
>>>
>>>> Subject: Re: [RFT PATCH v2 4/5] mm: provide more accurate estimation
>>>> of pages occupied by memmap
>>>
>>> How are people to test this?  "does it boot"?
>>>
>>
>> I've been running kernels with Gerry's 5 patches applied for 11 days
>> now. This is on a 64bit laptop but with a 32bit kernel + HIGHMEM. I
>> joined the conversation because my laptop would not resume from suspend
>> to disk - it either froze or rebooted. With the patches applied the
>> laptop does successfully resume and has been stable.
>>
>> Since Monday, I have have been running a kernel with the patches (plus,
>> from today, the patch you mailed yesterday) applied to 3.7rc7, without
>> problems.
>>
>
> I've been running 3.7-rc7 with the patches listed below for a week now
> and it has been perfectly stable. In particular, my laptop will now
> successfully resume from suspend to disk, which always failed without
> the patches.
>

I should have said, of course, that it was -rc6 and earlier that would 
not boot without Jiang Liu's patches. I applied those patches to rc-6 
and my resume after suspend to disk problem was fixed. For a subsequent 
week I have been running with the patches applied to -rc7, with Andrew's 
patch also applied for the last 3 days. -rc7 was not subject to the 
resume problem because the patch which broke it had been reverted.
All this has been on a 64bit laptop, but running a 32bit kernel with 
HIGHMEM.

Apologies for yesterday's inaccuracy. I shouldn't send testing reports 
when I'm in a hurry.

>  From Jiang Liu:
> 1. [RFT PATCH v2 1/5] mm: introduce new field "managed_pages" to struct
> zone
> 2. [RFT PATCH v1 2/5] mm: replace zone->present_pages with
> zone->managed_pages if appreciated
> 3. [RFT PATCH v1 3/5] mm: set zone->present_pages to number of existing
> pages in the zone
> 4. [RFT PATCH v2 4/5] mm: provide more accurate estimation of pages
> occupied by memmap
> 5. [RFT PATCH v1 5/5] mm: increase totalram_pages when free pages
> allocated by bootmem allocator
>
>  From Andrew Morton:
> 6. mm-provide-more-accurate-estimation-of-pages-occupied-by-memmap.patch
>
> Tested-by: Chris Clayton <chris2553@googlemail.com>
>
>> Thanks,
>> Chris
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
