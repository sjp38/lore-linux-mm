Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D9DCF6B0253
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 11:47:11 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l68so151030056wml.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:47:11 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id j76si19959287wmj.21.2016.03.15.08.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 08:47:10 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id l68so32753925wml.1
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 08:47:10 -0700 (PDT)
Date: Tue, 15 Mar 2016 18:47:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Page migration issue with UBIFS
Message-ID: <20160315154708.GC16462@node.shutemov.name>
References: <56E8192B.5030008@nod.at>
 <20160315151727.GA16462@node.shutemov.name>
 <56E8297E.80708@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E8297E.80708@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Boris Brezillon <boris.brezillon@free-electrons.com>, Maxime Ripard <maxime.ripard@free-electrons.com>, David Gstir <david@sigma-star.at>, Dave Chinner <david@fromorbit.com>, Artem Bityutskiy <dedekind1@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Kaplan <alex@nextthing.co>

On Tue, Mar 15, 2016 at 04:25:50PM +0100, Richard Weinberger wrote:
> Kirill,
> 
> Am 15.03.2016 um 16:17 schrieb Kirill A. Shutemov:
> > On Tue, Mar 15, 2016 at 03:16:11PM +0100, Richard Weinberger wrote:
> >> Hi!
> >>
> >> We're facing this issue from 2014 on UBIFS:
> >> http://www.spinics.net/lists/linux-fsdevel/msg79941.html
> >>
> >> So sum up:
> >> UBIFS does not allow pages directly marked as dirty. It want's everyone to do it via UBIFS's
> >> ->wirte_end() and ->page_mkwirte() functions.
> >> This assumption *seems* to be violated by CMA which migrates pages.
> > 
> > I don't thing the CMA/migration is the root cause.
> > 
> > How did we end up with writable and dirty pte, but not having
> > ->page_mkwrite() called for the page?
> > 
> > Or if ->page_mkwrite() was called, why the page is not dirty?
> 
> Thanks for your quick response!
> 
> I also don't think that the root cause is CMA or migration but it seems
> to be the messenger.
> 
> Can you confirm that UBIFS's assumptions are valid?
> I'm trying to rule out possible issues and hunt down the root cause...

The assumption looks reasonable for me, but I am not confident enough to
"confirm" it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
