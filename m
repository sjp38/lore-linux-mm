Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 18AE86B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 08:02:06 -0400 (EDT)
Received: by ywh42 with SMTP id 42so1209865ywh.30
        for <linux-mm@kvack.org>; Thu, 27 Aug 2009 05:02:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090825105341.GB21335@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org>
	 <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com>
	 <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com>
	 <20090819100553.GE24809@csn.ul.ie>
	 <202cde0e0908232314j4b90aa61pb4bcd0223ffbc087@mail.gmail.com>
	 <20090825105341.GB21335@csn.ul.ie>
Date: Fri, 28 Aug 2009 00:02:05 +1200
Message-ID: <202cde0e0908270502p3ea403ddr516945084372ffc4@mail.gmail.com>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>
>> If reservation only, then it is necessary to keep a gfp_mask for a
>> file somewhere. Would it be Ok to keep a gfp_mask for a file in
>> file->private_data?
>>
>
> I'm not seeing where this gfp mask is coming out of if you don't have zone
> limitations. GFP masks don't help you get contiguity beyond the hugepage
> boundary.
Contiguity is different. It is not related to GFP mask.
Requirement to have large contigous buffer is dictated by h/w. Since
this is very specific case it will need very specific solution. So if
providing this, affects on usability of kernel interfaces it's better
to left interfaces good.
But large DMA buffers with large amount of sg regions is more common.
DMA engine often requires 32 address space. Plus memory must be non
movable.
That raises another question: would it be correct assumiing that
setting sysctl hugepages_treat_as_movable won't make huge pages
movable?
>
> If you did need the GFP mask, you could store it in hugetlbfs_inode_info
> as you'd expect all users of that inode to have the same GFP
> requirements, right?
Correct. The same GFP per inode is quite enough.
So that way works. I made a bit raw implementation, more testing and
tuning and I'll send out another version.

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
