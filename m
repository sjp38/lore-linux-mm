Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id B8A1B6B005D
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 16:53:51 -0400 (EDT)
Date: Tue, 14 Aug 2012 20:53:50 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm, slob: Drop usage of page->private for storing
 page-sized allocations
In-Reply-To: <1344974585-9701-1-git-send-email-elezegarcia@gmail.com>
Message-ID: <0000013926e9f534-137f9d40-77b0-4dbc-90cb-d588c68e9526-000000@email.amazonses.com>
References: <1344974585-9701-1-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

On Tue, 14 Aug 2012, Ezequiel Garcia wrote:

> This field was being used to store size allocation so it could be
> retrieved by ksize(). However, it is a bad practice to not mark a page
> as a slab page and then use fields for special purposes.
> There is no need to store the allocated size and
> ksize() can simply return PAGE_SIZE << compound_order(page).

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
