Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id E255F6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:52:28 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2467508pbb.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 13:52:28 -0700 (PDT)
Date: Thu, 31 May 2012 13:52:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: change cmpxchg_double_slab in get_freelist() to
 __cmpxchg_double_slab
In-Reply-To: <alpine.DEB.2.00.1205142332060.19403@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1205311351540.2764@chino.kir.corp.google.com>
References: <1336665378-2967-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1205142332060.19403@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 14 May 2012, David Rientjes wrote:

> On Fri, 11 May 2012, Joonsoo Kim wrote:
> 
> > get_freelist() is only called by __slab_alloc with interrupt disabled,
> > so __cmpxchg_double_slab is suitable.
> > 
> > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 

Pekka, did you want to pick this up so it can get into linux-next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
