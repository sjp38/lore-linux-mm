Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 778C16B0062
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 15:35:02 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so3527693pbb.14
        for <linux-mm@kvack.org>; Wed, 19 Sep 2012 12:35:01 -0700 (PDT)
Date: Wed, 19 Sep 2012 12:34:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/sl[aou]b: Shrink __kmem_cache_create() parameter
 lists fix
In-Reply-To: <1348060101-32288-1-git-send-email-haggaie@mellanox.com>
Message-ID: <alpine.DEB.2.00.1209191234480.749@chino.kir.corp.google.com>
References: <1348060101-32288-1-git-send-email-haggaie@mellanox.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Wed, 19 Sep 2012, Haggai Eran wrote:

> Fixes compilation with CONFIG_DEBUG_PAGEALLOC, which was broken when the align
> parameter was removed.
> 
> Signed-off-by: Haggai Eran <haggaie@mellanox.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
