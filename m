Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 463226B0069
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:10:08 -0400 (EDT)
Date: Fri, 19 Oct 2012 14:10:07 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm/slob: Use object_size field in
 kmem_cache_size()
In-Reply-To: <1350649992-25988-2-git-send-email-elezegarcia@gmail.com>
Message-ID: <0000013a795c0df5-32399699-2e0d-4ecf-a902-be4c6da61c98-000000@email.amazonses.com>
References: <1350649992-25988-1-git-send-email-elezegarcia@gmail.com> <1350649992-25988-2-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Fri, 19 Oct 2012, Ezequiel Garcia wrote:

> Fields object_size and size are not the same: the latter might include
> slab metadata. Return object_size field in kmem_cache_size().
> Also, improve trace accuracy by correctly tracing reported size.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
