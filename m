Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 16A516B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 18:51:02 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so9922761pbb.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 15:51:01 -0700 (PDT)
Date: Thu, 18 Oct 2012 15:50:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm/slob: Use object_size field in
 kmem_cache_size()
In-Reply-To: <1350600107-4558-2-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1210181550100.4902@chino.kir.corp.google.com>
References: <1350600107-4558-1-git-send-email-elezegarcia@gmail.com> <1350600107-4558-2-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Thu, 18 Oct 2012, Ezequiel Garcia wrote:

> Fields object_size and size are not the same: the latter might include
> slab metadata. Return object_size field in kmem_cache_size().
> Also, improve trace accuracy by correctly tracing reported size.
> 
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
