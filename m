Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 451496B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 10:52:53 -0400 (EDT)
Date: Tue, 14 Aug 2012 14:52:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm, slob: Prevent false positive trace upon allocation
 failure
In-Reply-To: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
Message-ID: <00000139259ef8c5-2712ec60-9b7f-4d5c-955a-e38da1772402-000000@email.amazonses.com>
References: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

On Tue, 14 Aug 2012, Ezequiel Garcia wrote:

> This patch changes the __kmalloc_node() logic to return NULL
> if alloc_pages() fails to return valid pages.
> This is done to avoid to trace a false positive kmalloc event.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
