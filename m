Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 898936B006E
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 13:44:42 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so2326133wiw.1
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 10:44:42 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id r4si3584643wix.68.2014.12.05.10.44.41
        for <linux-mm@kvack.org>;
        Fri, 05 Dec 2014 10:44:41 -0800 (PST)
Date: Fri, 5 Dec 2014 18:44:18 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC v2] arm:extend the reserved mrmory for initrd to be page
 aligned
Message-ID: <20141205184418.GF31222@e104818-lin.cambridge.arm.com>
References: <35FD53F367049845BC99AC72306C23D103D6DB491609@CNBJMBX05.corpusers.net>
 <20140915113325.GD12361@n2100.arm.linux.org.uk>
 <20141204120305.GC17783@e104818-lin.cambridge.arm.com>
 <20141205120506.GH1630@arm.com>
 <20141205170745.GA31222@e104818-lin.cambridge.arm.com>
 <20141205172701.GW11285@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141205172701.GW11285@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Will Deacon <Will.Deacon@arm.com>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, Peter Maydell <Peter.Maydell@arm.com>

On Fri, Dec 05, 2014 at 05:27:02PM +0000, Russell King - ARM Linux wrote:
> On Fri, Dec 05, 2014 at 05:07:45PM +0000, Catalin Marinas wrote:
> > From 8e317c6be00abe280de4dcdd598d2e92009174b6 Mon Sep 17 00:00:00 2001
> > From: Catalin Marinas <catalin.marinas@arm.com>
> > Date: Fri, 5 Dec 2014 16:41:52 +0000
> > Subject: [PATCH] Revert "ARM: 8167/1: extend the reserved memory for initrd to
> >  be page aligned"
> > 
> > This reverts commit 421520ba98290a73b35b7644e877a48f18e06004. There is
> > no guarantee that the boot-loader places other images like dtb in a
> > different page than initrd start/end. When this happens, such pages must
> > not be freed. The free_reserved_area() already takes care of rounding up
> > "start" and rounding down "end" to avoid freeing partially used pages.
> > 
> > In addition to the revert, this patch also removes the arm32
> > PAGE_ALIGN(end) when calculating the size of the memory to be poisoned.
> 
> which makes the summary line rather misleading, and I really don't think
> we need to do this on ARM for the simple reason that we've been doing it
> for soo long that it can't be an issue.

I started this as a revert and then realised that it doesn't solve
anything for arm32 without changing the poisoning.

Anyway, if you are happy with how it is, I'll drop the arm32 part. As I
said yesterday, the issue is worse for arm64 with 64K pages.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
