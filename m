Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 28BD76B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 17:49:51 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so11252961pac.19
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 14:49:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id vy9si28260303pbc.69.2014.07.01.14.49.49
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 14:49:50 -0700 (PDT)
Date: Tue, 1 Jul 2014 14:49:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: slub: invalid memory access in setup_object
Message-Id: <20140701144947.5ce3f93729759d8f38d7813a@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1407010956470.5353@gentwo.org>
References: <53AAFDF7.2010607@oracle.com>
	<alpine.DEB.2.11.1406251228130.29216@gentwo.org>
	<alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com>
	<alpine.DEB.2.11.1407010956470.5353@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Tue, 1 Jul 2014 09:58:52 -0500 (CDT) Christoph Lameter <cl@gentwo.org> wrote:

> On Mon, 30 Jun 2014, David Rientjes wrote:
> 
> > It's not at all clear to me that that patch is correct.  Wei?
> 
> Looks ok to me. But I do not like the convoluted code in new_slab() which
> Wei's patch does not make easier to read. Makes it difficult for the
> reader to see whats going on.
> 
> Lets drop the use of the variable named "last".
> 
> 
> Subject: slub: Only call setup_object once for each object
> 
> Modify the logic for object initialization to be less convoluted
> and initialize an object only once.
> 

Well, um.  Wei's changelog was much better:

: When a kmem_cache is created with ctor, each object in the kmem_cache will
: be initialized before use.  In the slub implementation, the first object
: will be initialized twice.
: 
: This patch avoids the duplication of initialization of the first object.
: 
: Fixes commit 7656c72b5a63: ("SLUB: add macros for scanning objects in a
: slab").

I can copy that text over and add the reported-by etc (ho hum) but I
have a tiny feeling that this patch hasn't been rigorously tested? 
Perhaps someone (Wei?) can do that?

And we still don't know why Sasha's kernel went oops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
