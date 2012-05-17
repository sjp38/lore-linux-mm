Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id A94376B00E9
	for <linux-mm@kvack.org>; Thu, 17 May 2012 12:49:36 -0400 (EDT)
Date: Thu, 17 May 2012 11:49:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1,2/4 v2] slub: use __cmpxchg_double_slab() at interrupt
 disabled place
In-Reply-To: <1337272864-5090-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205171149050.8534@router.home>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com> <1337272864-5090-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 18 May 2012, Joonsoo Kim wrote:

> get_freelist() is only called by __slab_alloc() with interrupt disabled,
> so __cmpxchg_double_slab() is suitable.
>
> unfreeze_partials() is only called with interrupt disabled,
> so __cmpxchg_double_slab() is suitable.

Combine these sentences as well.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
