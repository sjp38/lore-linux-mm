Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEAD86B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 18:01:19 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so41399270wme.4
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 15:01:19 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id t1si2027756wjy.22.2016.11.09.15.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 15:01:18 -0800 (PST)
Date: Wed, 9 Nov 2016 15:01:17 -0800
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v3] z3fold: use per-page read/write lock
Message-ID: <20161109230117.GO26852@two.firstfloor.org>
References: <20161109115531.81d2a3fd4313236d483510f0@gmail.com>
 <20161109143304.538885b06a4b5d2289da1e52@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161109143304.538885b06a4b5d2289da1e52@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Wool <vitalywool@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andi Kleen <andi@firstfloor.org>

On Wed, Nov 09, 2016 at 02:33:04PM -0800, Andrew Morton wrote:
> On Wed, 9 Nov 2016 11:55:31 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
> 
> > Subject: [PATCH v3] z3fold: use per-page read/write lock
> 
> I've rewritten the title to "mm/z3fold.c: use per-page spinlock"
> 
> (I prefer to have "mm" in the title to easily identify it as an MM
> patch, and using "mm: z3fold: ..." seems odd when the actual pathname
> conveys the same info.)

Still think it needs to be raw_spinlock_t, otherwise the build bug on
on the header size will break again. 

Better would be to fix that build bug though

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
