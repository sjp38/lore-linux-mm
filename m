Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0B7EA6B0092
	for <linux-mm@kvack.org>; Tue, 15 May 2012 02:32:21 -0400 (EDT)
Received: by dakp5 with SMTP id p5so10068370dak.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 23:32:21 -0700 (PDT)
Date: Mon, 14 May 2012 23:32:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: change cmpxchg_double_slab in get_freelist() to
 __cmpxchg_double_slab
In-Reply-To: <1336665378-2967-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205142332060.19403@chino.kir.corp.google.com>
References: <1336665378-2967-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 May 2012, Joonsoo Kim wrote:

> get_freelist() is only called by __slab_alloc with interrupt disabled,
> so __cmpxchg_double_slab is suitable.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
