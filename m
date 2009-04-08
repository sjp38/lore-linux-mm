Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8BFD05F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 02:23:44 -0400 (EDT)
Date: Wed, 8 Apr 2009 08:26:21 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [2/16] POISON: Add page flag for poisoned pages
Message-ID: <20090408062621.GG17934@one.firstfloor.org>
References: <20090407509.382219156@firstfloor.org> <20090407150958.BA68F1D046D@basil.firstfloor.org> <20090408002941.GA14041@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090408002941.GA14041@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Russ Anderson <rja@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

> > @@ -104,6 +107,9 @@
> >  #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
> >  	PG_uncached,		/* Page has been mapped as uncached */
> >  #endif
> > +#ifdef CONFIG_MEMORY_FAILURE
> 
> Is it necessary to have this under CONFIG_MEMORY_FAILURE?

That was mainly so that !MEMORY_FAILURE 32bits NUMA architectures who
might not use sparsemap/vsparsemap get a few more zone bits in page flags
to play with. Not sure those really exist, so it might be indeed
redundant, but it seemed safer.


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
