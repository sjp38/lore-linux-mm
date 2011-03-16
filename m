Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 520518D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 17:51:29 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p2GLpLNO007607
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:51:22 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq5.eem.corp.google.com with ESMTP id p2GLp4df021860
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:51:20 -0700
Received: by pzk2 with SMTP id 2so470304pzk.37
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 14:51:19 -0700 (PDT)
Date: Wed, 16 Mar 2011 14:51:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/8] mm/slub: Factor out some common code.
In-Reply-To: <20110316205139.2035.qmail@science.horizon.com>
Message-ID: <alpine.DEB.2.00.1103161352150.11002@chino.kir.corp.google.com>
References: <20110316205139.2035.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 16 Mar 2011, George Spelvin wrote:

> > Where's your signed-off-by?
> 
> Somewhere under the pile of crap on my desk. :-)
> (More to the point, waiting for me to think it's good enough to submit
> For Real.)
> 

Patches that you would like to propose but don't think are ready for merge 
should have s/PATCH/RFC/ done on the subject line.

> > Nice cleanup.
> > 
> > "flag" should be unsigned long in all of these functions: the constants 
> > are declared with UL suffixes in slab.h.
> 
> Actually, I did that deliberately.  Because there's a problem I keep
> wondering about, which repeats many many times in the kernel:
> 

You deliberately created a helper function to take an unsigned int when 
the actuals being passed in are all unsigned long to trigger a discussion 
on why they are unsigned long?

> *Why* are they unsigned long?  That's an awkward type: 32 bits on many
> architectures, so we can't portably assign more than 32 bits, and on
> platforms where it's 64 bits, the upper 32 are just wasting space.
> (And REX prefixes on x86-64.)
> 

unsigned long uses the native word size of the architecture which can 
generate more efficient code; we typically imply that flags have a limited 
size by including leading zeros in their definition for 32-bit 
compatibility:

#define SLAB_DEBUG_FREE         0x00000100UL    /* DEBUG: Perform (expensive) checks on free */
#define SLAB_RED_ZONE           0x00000400UL    /* DEBUG: Red zone objs in a cache */
#define SLAB_POISON             0x00000800UL    /* DEBUG: Poison objects */
...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
