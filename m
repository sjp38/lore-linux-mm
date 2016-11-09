Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11A1F6B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 17:33:06 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 144so74621409pfv.5
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 14:33:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gv1si1261205pac.69.2016.11.09.14.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 14:33:05 -0800 (PST)
Date: Wed, 9 Nov 2016 14:33:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] z3fold: use per-page read/write lock
Message-Id: <20161109143304.538885b06a4b5d2289da1e52@linux-foundation.org>
In-Reply-To: <20161109115531.81d2a3fd4313236d483510f0@gmail.com>
References: <20161109115531.81d2a3fd4313236d483510f0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andi Kleen <andi@firstfloor.org>

On Wed, 9 Nov 2016 11:55:31 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:

> Subject: [PATCH v3] z3fold: use per-page read/write lock

I've rewritten the title to "mm/z3fold.c: use per-page spinlock"

(I prefer to have "mm" in the title to easily identify it as an MM
patch, and using "mm: z3fold: ..." seems odd when the actual pathname
conveys the same info.)

> 
> Most of z3fold operations are in-page, such as modifying z3fold
> page header or moving z3fold objects within a page. Taking
> per-pool spinlock to protect per-page objects is therefore
> suboptimal, and the idea of having a per-page spinlock (or rwlock)
> has been around for some time. However, adding one directly to the
> z3fold header makes the latter quite big on some systems so that
> it won't fit in a signle chunk.
> 
> This patch implements spinlock-based per-page locking mechanism
> which is lightweight enough to fit into the z3fold header.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
