Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 56E8E6B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 09:15:19 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id h18so3879139igc.15
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 06:15:19 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id f2si22829090pdk.241.2014.09.15.06.15.18
        for <linux-mm@kvack.org>;
        Mon, 15 Sep 2014 06:15:18 -0700 (PDT)
Date: Mon, 15 Sep 2014 14:15:06 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC Resend] arm:extend __init_end to a page align address
Message-ID: <20140915131505.GB5415@arm.com>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB028@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103D6DB4915FB@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103D6DB491607@CNBJMBX05.corpusers.net>
 <20140915105525.GC12361@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140915105525.GC12361@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, Jiang Liu <jiang.liu@huawei.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Mon, Sep 15, 2014 at 11:55:25AM +0100, Russell King - ARM Linux wrote:
> On Mon, Sep 15, 2014 at 06:26:43PM +0800, Wang, Yalin wrote:
> > this patch change the __init_end address to a page align address, so that free_initmem()
> > can free the whole .init section, because if the end address is not page aligned,
> > it will round down to a page align address, then the tail unligned page will not be freed.
> 
> Please wrap commit messages at or before column 72 - this makes "git log"
> much easier to read once the change has been committed.
> 
> I have no objection to the arch/arm part of this patch.  However, since
> different people deal with arch/arm and arch/arm64, this patch needs to
> be split.

I don't mind how it goes in. If Russell is ok to take the whole patch:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
