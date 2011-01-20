Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 750938D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:43:42 -0500 (EST)
Received: by iyj17 with SMTP id 17so819837iyj.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 09:43:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTinXAiShaf1f69ufVHg7KPaY5j=jmOTtK71GNNp5@mail.gmail.com>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
	<20110120142844.GA28358@barrios-desktop>
	<AANLkTinXAiShaf1f69ufVHg7KPaY5j=jmOTtK71GNNp5@mail.gmail.com>
Date: Fri, 21 Jan 2011 02:43:22 +0900
Message-ID: <AANLkTikBbknwsLvN-b4HVqL_gAUHC-4VjQ=WQ=h_kLhW@mail.gmail.com>
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.linux@gmail.com>, inux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene.kim@samsung.com>, Ilho Lee <ilho215.lee@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, KyongHo Cho <pullip.cho@samsung.com>
List-ID: <linux-mm.kvack.org>

Restore Cced.

On Fri, Jan 21, 2011 at 2:24 AM, KyongHo Cho <pullip.linux@gmail.com> wrote:
> On Thu, Jan 20, 2011 at 11:28 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
>> On Thu, Jan 20, 2011 at 06:45:39PM +0900, KyongHo Cho wrote:
>>> Sparsemem allows that a bank of memory spans over several adjacent
>>> sections if the start address and the end address of the bank
>>> belong to different sections.
>>> When gathering statictics of physical memory in mem_init() and
>>> show_mem(), this possiblity was not considered.
>>
>> Please write down the result if we doesn't consider this patch.
>> I can understand what happens but for making good description and review,
>> merging easily, it would be better to write down the result without
>> the patch explicitly.
>>
> As we know that each section has its own memmap and
> a contiguous chunk of physical memory that is represented by 'bank' in meminfo
> can be larger than the size of a section.
> "page++" in the current implementation can access invalid memory area.
> The size of the section is 256 MiB in ARM and the number of banks in
> meminfo is 8.
> This means that the maximum size of the physical memory cannot be grow than 2GiB
> to avoid this problem in the current implementation.
> Thus we need to fix the calculation of the last page descriptor in
> terms of sections.
>
> This patch determines the last page descriptor in a memmap with
> min(last_pfn_of_bank, last_pfn_of_current_section)
> If there remains physical memory not consumed, it calculates the last
> page descriptor
> with min(last_pfn_of_bank, last_pfn_of_next_section).
>
>>
>> Hmm.. new ifndef magic makes code readability bad.
>> Couldn't we do it by simple pfn iterator not page and pfn_valid check?
>>
> True.
> We need to consider the implementation again.
> I think the previous implementation gave the importance to the
> efficiency but to the readability.
>

Please consider readability and consistency with other architectures
if we can do. :)
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
