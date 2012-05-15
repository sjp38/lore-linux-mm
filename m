Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 014C76B0081
	for <linux-mm@kvack.org>; Tue, 15 May 2012 02:28:55 -0400 (EDT)
Received: by dakp5 with SMTP id p5so10061553dak.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 23:28:55 -0700 (PDT)
Date: Mon, 14 May 2012 23:28:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: fix a possible memory leak
In-Reply-To: <1336663979-2611-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205142327580.19403@chino.kir.corp.google.com>
References: <1336663979-2611-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 May 2012, Joonsoo Kim wrote:

> Memory allocated by kstrdup should be freed,
> when kmalloc(kmem_size, GFP_KERNEL) is failed.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

kmem_cache_create() in slub would significantly be improved with a rewrite 
to have a clear error path and use of return values of functions it calls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
