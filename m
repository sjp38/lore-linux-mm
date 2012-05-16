Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 39A266B00F0
	for <linux-mm@kvack.org>; Wed, 16 May 2012 02:36:16 -0400 (EDT)
Received: by lahi5 with SMTP id i5so428636lah.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 23:36:14 -0700 (PDT)
Date: Wed, 16 May 2012 09:35:40 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slub: fix a memory leak in get_partial_node()
In-Reply-To: <alpine.DEB.2.00.1205151527150.11923@router.home>
Message-ID: <alpine.LFD.2.02.1205160935340.1763@tux.localdomain>
References: <1337108498-4104-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1205151527150.11923@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

<On Tue, 15 May 2012, Christoph Lameter wrote:

> On Wed, 16 May 2012, Joonsoo Kim wrote:
> 
> > In the case which is below,
> >
> > 1. acquire slab for cpu partial list
> > 2. free object to it by remote cpu
> > 3. page->freelist = t
> >
> > then memory leak is occurred.
> 
> Hmmm... Ok so we cannot assign page->freelist in get_partial_node() for
> the cpu partial slabs. It must be done in the cmpxchg transition.
> 
> Acked-by: Christoph Lameter <cl@linux.com>

Joonsoo, can you please fix up the stable submission format, add 
Christoph's ACK and resend?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
