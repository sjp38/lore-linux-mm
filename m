Date: Sat, 19 May 2007 11:19:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 01/10] SLUB: add support for kmem_cache_ops
In-Reply-To: <84144f020705190553s598e722fu7279253ee8b516bc@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0705191119010.17008@schroedinger.engr.sgi.com>
References: <20070518181040.465335396@sgi.com>  <20070518181118.828853654@sgi.com>
 <84144f020705190553s598e722fu7279253ee8b516bc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Sat, 19 May 2007, Pekka Enberg wrote:

> On 5/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> > kmem_cache_ops is created as empty. Later patches populate kmem_cache_ops.
> 
> Hmm, would make more sense to me to move "ctor" in kmem_cache_ops in
> this patch and not make kmem_cache_create() take both as parameters...

Yeah earlier versions did this but then I have to do a patch that changes 
all destructors and all kmem_cache_create calls in the kernel.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
