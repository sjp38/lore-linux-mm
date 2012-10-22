Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id D3F136B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 10:31:44 -0400 (EDT)
Date: Mon, 22 Oct 2012 14:31:43 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH for-v3.7 2/2] slub: optimize kmalloc* inlining for
 GFP_DMA
In-Reply-To: <1350748093-7868-2-git-send-email-js1304@gmail.com>
Message-ID: <0000013a88e2e9dc-9f72abd3-9a31-454c-b70b-9937ba54c0ee-000000@email.amazonses.com>
References: <Yes> <1350748093-7868-1-git-send-email-js1304@gmail.com> <1350748093-7868-2-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 21 Oct 2012, Joonsoo Kim wrote:

> kmalloc() and kmalloc_node() of the SLUB isn't inlined when @flags = __GFP_DMA.
> This patch optimize this case,
> so when @flags = __GFP_DMA, it will be inlined into generic code.

__GFP_DMA is a rarely used flag for kmalloc allocators and so far it was
not considered that it is worth to directly support it in the inlining
code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
