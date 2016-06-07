Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 465B16B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 19:32:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so45203981pfa.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 16:32:32 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id wa12si1039457pac.138.2016.06.07.16.32.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 16:32:30 -0700 (PDT)
Date: Wed, 8 Jun 2016 09:31:57 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: Tree for Jun 6 (mm/slub.c)
Message-ID: <20160608093157.51225c43@canb.auug.org.au>
In-Reply-To: <20160607131242.fac39cbade676df24d70edaa@linux-foundation.org>
References: <20160606142058.44b82e38@canb.auug.org.au>
	<57565789.9050508@infradead.org>
	<20160607131242.fac39cbade676df24d70edaa@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Thomas Garnier <thgarnie@google.com>

Hi Andrew,

On Tue, 7 Jun 2016 13:12:42 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon, 6 Jun 2016 22:11:37 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> 
> > On 06/05/16 21:20, Stephen Rothwell wrote:  
> > > Hi all,
> > > 
> > > Changes since 20160603:
> > >   
> > 
> > on i386:
> > 
> > mm/built-in.o: In function `init_cache_random_seq':
> > slub.c:(.text+0x76921): undefined reference to `cache_random_seq_create'
> > mm/built-in.o: In function `__kmem_cache_release':
> > (.text+0x80525): undefined reference to `cache_random_seq_destroy'  
> 
> Yup.  This, I guess...
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-slub-freelist-randomization-fix

Applied to linux-next today.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
