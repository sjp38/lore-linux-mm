Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 009BA6B005C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 03:10:51 -0400 (EDT)
Subject: Re: [this_cpu_xx V2 13/19] Use this_cpu operations in slub
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <alpine.DEB.1.10.0906180957030.15556@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
	 <20090617203445.302169275@gentwo.org>
	 <84144f020906172320k39ea5132h823449abc3124b30@mail.gmail.com>
	 <alpine.DEB.1.10.0906180957030.15556@gentwo.org>
Date: Thu, 25 Jun 2009 10:11:06 +0300
Message-Id: <1245913866.2018.27.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jun 2009, Pekka Enberg wrote:
> > On Wed, Jun 17, 2009 at 11:33 PM, <cl@linux-foundation.org> wrote:
> > > @@ -1604,9 +1595,6 @@ static void *__slab_alloc(struct kmem_ca
> > >        void **object;
> > >        struct page *new;
> > >
> > > -       /* We handle __GFP_ZERO in the caller */
> > > -       gfpflags &= ~__GFP_ZERO;
> > > -
> >
> > This should probably not be here.

On Thu, 2009-06-18 at 09:59 -0400, Christoph Lameter wrote:
> Yes how did this get in there? Useless code somehow leaked in.

Hmm, you know as well as I do that Linus added it after a flame fest :)

The change has nothing to do with this series so lets keep it out of the
patch, OK?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
