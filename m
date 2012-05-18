Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 96A246B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 05:31:42 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so3220231lbj.14
        for <linux-mm@kvack.org>; Fri, 18 May 2012 02:31:40 -0700 (PDT)
Date: Fri, 18 May 2012 12:31:37 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 1,2/4 v2] slub: use __cmpxchg_double_slab() at interrupt
 disabled place
In-Reply-To: <alpine.DEB.2.00.1205171149050.8534@router.home>
Message-ID: <alpine.LFD.2.02.1205181231170.3899@tux.localdomain>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com> <1337272864-5090-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1205171149050.8534@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 17 May 2012, Christoph Lameter wrote:

> On Fri, 18 May 2012, Joonsoo Kim wrote:
> 
> > get_freelist() is only called by __slab_alloc() with interrupt disabled,
> > so __cmpxchg_double_slab() is suitable.
> >
> > unfreeze_partials() is only called with interrupt disabled,
> > so __cmpxchg_double_slab() is suitable.
> 
> Combine these sentences as well.
> 
> Acked-by: Christoph Lameter <cl@linux.com>

You should add a comment on top of get_freelist() and unfreeze_partials() 
that they now *require* interrupts to be disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
