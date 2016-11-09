Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 58FED6B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 18:25:23 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so3194058wmf.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 15:25:23 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x130si2802456wmg.27.2016.11.09.15.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 15:25:18 -0800 (PST)
Date: Thu, 10 Nov 2016 00:22:44 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3] z3fold: use per-page read/write lock
In-Reply-To: <20161109230117.GO26852@two.firstfloor.org>
Message-ID: <alpine.DEB.2.20.1611100020570.3501@nanos>
References: <20161109115531.81d2a3fd4313236d483510f0@gmail.com> <20161109143304.538885b06a4b5d2289da1e52@linux-foundation.org> <20161109230117.GO26852@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Wool <vitalywool@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

On Wed, 9 Nov 2016, Andi Kleen wrote:

> On Wed, Nov 09, 2016 at 02:33:04PM -0800, Andrew Morton wrote:
> > On Wed, 9 Nov 2016 11:55:31 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
> > 
> > > Subject: [PATCH v3] z3fold: use per-page read/write lock
> > 
> > I've rewritten the title to "mm/z3fold.c: use per-page spinlock"
> > 
> > (I prefer to have "mm" in the title to easily identify it as an MM
> > patch, and using "mm: z3fold: ..." seems odd when the actual pathname
> > conveys the same info.)
> 
> Still think it needs to be raw_spinlock_t, otherwise the build bug on
> on the header size will break again. 

raw spinlocks in mainline are not smaller than spinlocks, that's only true
for RT. What's smaller are arch spinlocks, but then they evade debugging as
well.

> Better would be to fix that build bug though

Indeed.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
