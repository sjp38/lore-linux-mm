Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D708B6B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 18:53:00 -0500 (EST)
Received: by pablf10 with SMTP id lf10so26398968pab.12
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 15:53:00 -0800 (PST)
Received: from mail-gw2-out.broadcom.com (mail-gw2-out.broadcom.com. [216.31.210.63])
        by mx.google.com with ESMTP id eq3si5554146pbb.228.2015.02.27.15.52.59
        for <linux-mm@kvack.org>;
        Fri, 27 Feb 2015 15:53:00 -0800 (PST)
Message-ID: <54F10358.1050102@broadcom.com>
Date: Fri, 27 Feb 2015 15:52:56 -0800
From: Danesh Petigara <dpetigara@broadcom.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: cma: fix CMA aligned offset calculation
References: <1424821185-16956-1-git-send-email-dpetigara@broadcom.com> <20150227132443.e17d574d45451f10f413f065@linux-foundation.org>
In-Reply-To: <20150227132443.e17d574d45451f10f413f065@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: m.szyprowski@samsung.com, mina86@mina86.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, laurent.pinchart+renesas@ideasonboard.com, gregory.0xf0@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 2/27/2015 1:24 PM, Andrew Morton wrote:
> On Tue, 24 Feb 2015 15:39:45 -0800 Danesh Petigara <dpetigara@broadcom.com> wrote:
> 
>> The CMA aligned offset calculation is incorrect for
>> non-zero order_per_bit values.
>>
>> For example, if cma->order_per_bit=1, cma->base_pfn=
>> 0x2f800000 and align_order=12, the function returns
>> a value of 0x17c00 instead of 0x400.
>>
>> This patch fixes the CMA aligned offset calculation.
> 
> When fixing a bug please always describe the end-user visible effects
> of that bug.
> 
> Without that information others are unable to understand why you are
> recommending a -stable backport.
> 

Thank you for the feedback. I had no crash logs to show, nevertheless, I
agree that a sentence describing potential effects of the bug would've
helped.

I'll keep that in mind for future submissions.

Best Regards,
Danesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
