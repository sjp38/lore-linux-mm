Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D1DE86B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 18:55:00 -0500 (EST)
Received: by padfa1 with SMTP id fa1so26486896pad.2
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 15:55:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pt4si5033157pbc.218.2015.02.27.15.54.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 15:55:00 -0800 (PST)
Date: Fri, 27 Feb 2015 15:54:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: cma: fix CMA aligned offset calculation
Message-Id: <20150227155458.697b7701d0a67ff7b4f3d9cb@linux-foundation.org>
In-Reply-To: <54F10358.1050102@broadcom.com>
References: <1424821185-16956-1-git-send-email-dpetigara@broadcom.com>
	<20150227132443.e17d574d45451f10f413f065@linux-foundation.org>
	<54F10358.1050102@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Danesh Petigara <dpetigara@broadcom.com>
Cc: m.szyprowski@samsung.com, mina86@mina86.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, laurent.pinchart+renesas@ideasonboard.com, gregory.0xf0@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Fri, 27 Feb 2015 15:52:56 -0800 Danesh Petigara <dpetigara@broadcom.com> wrote:

> On 2/27/2015 1:24 PM, Andrew Morton wrote:
> > On Tue, 24 Feb 2015 15:39:45 -0800 Danesh Petigara <dpetigara@broadcom.com> wrote:
> > 
> >> The CMA aligned offset calculation is incorrect for
> >> non-zero order_per_bit values.
> >>
> >> For example, if cma->order_per_bit=1, cma->base_pfn=
> >> 0x2f800000 and align_order=12, the function returns
> >> a value of 0x17c00 instead of 0x400.
> >>
> >> This patch fixes the CMA aligned offset calculation.
> > 
> > When fixing a bug please always describe the end-user visible effects
> > of that bug.
> > 
> > Without that information others are unable to understand why you are
> > recommending a -stable backport.
> > 
> 
> Thank you for the feedback. I had no crash logs to show, nevertheless, I
> agree that a sentence describing potential effects of the bug would've
> helped.

What was the reason for adding a cc:stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
