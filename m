Received: by ug-out-1314.google.com with SMTP id s2so1795309uge
        for <linux-mm@kvack.org>; Wed, 29 Nov 2006 23:12:29 -0800 (PST)
Message-ID: <84144f020611292312v573b9115tfd29aff49962ec97@mail.gmail.com>
Date: Thu, 30 Nov 2006 09:12:29 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC] Extract kmalloc.h and slob.h from slab.h
In-Reply-To: <456E3ACE.4040804@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0611272229290.6012@schroedinger.engr.sgi.com>
	 <20061129082650.GB12734@infradead.org> <456D4722.2010202@yahoo.com.au>
	 <Pine.LNX.4.64.0611291119480.16189@schroedinger.engr.sgi.com>
	 <456E3ACE.4040804@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, Christoph Hellwig <hch@infradead.org>, akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On 11/30/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> The point is that it *is the same API*. Having the declarations for the slob
> implementation in slob.h, and then including slab.h in slob.h seems completely
> backwards.

Agreed that it would be cleaner if we, for example, had <linux/kmem.h>
that included either <linux/slab.h> or <linux/slob.h> depending on
config. However, Christoph's split does make sense, the slob
_implementation_ is completely different in the header. It doesn't
have any of the inlining tricks we do for slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
