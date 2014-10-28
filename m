Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 68C51900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 09:48:31 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id w7so504045qcr.40
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 06:48:31 -0700 (PDT)
Received: from n23.mail01.mtsvc.net (mailout32.mail01.mtsvc.net. [216.70.64.70])
        by mx.google.com with ESMTPS id k2si2415145qaf.20.2014.10.28.06.48.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 06:48:30 -0700 (PDT)
Message-ID: <544F9EAA.5010404@hurleysoftware.com>
Date: Tue, 28 Oct 2014 09:48:26 -0400
From: Peter Hurley <peter@hurleysoftware.com>
MIME-Version: 1.0
Subject: Re: CMA: test_pages_isolated failures in alloc_contig_range
References: <2457604.k03RC2Mv4q@avalon> <xa1tsii8l683.fsf@mina86.com>
In-Reply-To: <xa1tsii8l683.fsf@mina86.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-sh@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

[ +cc Andrew Morton ]

On 10/28/2014 08:38 AM, Michal Nazarewicz wrote:
> On Sun, Oct 26 2014, Laurent Pinchart <laurent.pinchart@ideasonboard.com> wrote:
>> Hello,
>>
>> I've run into a CMA-related issue while testing a DMA engine driver with 
>> dmatest on a Renesas R-Car ARM platform. 
>>
>> When allocating contiguous memory through CMA the kernel prints the following 
>> messages to the kernel log.
>>
>> [   99.770000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
>> [  124.220000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
>> [  127.550000] alloc_contig_range test_pages_isolated(6b845, 6b846) failed
>> [  132.850000] alloc_contig_range test_pages_isolated(6b845, 6b846) failed
>> [  151.390000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
>> [  166.490000] alloc_contig_range test_pages_isolated(6b843, 6b844) failed
>> [  181.450000] alloc_contig_range test_pages_isolated(6b845, 6b846) failed
>>
>> I've stripped the dmatest module down as much as possible to remove any 
>> hardware dependencies and came up with the following implementation.
> 
> Like Laura wrote, the message is not (should not be) a problem in
> itself:

[...]

> So as you can see cma_alloc will try another part of the cma region if
> test_pages_isolated fails.
> 
> Obviously, if CMA region is fragmented or there's enough space for only
> one allocation of required size isolation failures will cause allocation
> failures, so it's best to avoid them, but they are not always avoidable.
> 
> To debug you would probably want to add more debug information about the
> page (i.e. data from struct page) that failed isolation after the
> pr_warn in alloc_contig_range.

If the message does not indicate an actual problem, then its printk level is
too high. These messages have been reported when using 3.16+ distro kernels.

Regards,
Peter Hurley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
