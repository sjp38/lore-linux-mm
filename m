Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 572DD6B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 08:07:53 -0400 (EDT)
Message-ID: <5085370F.80204@parallels.com>
Date: Mon, 22 Oct 2012 16:07:43 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/slob: Use free_page instead of put_page for page-size
 kmalloc allocations
References: <1350907471-2236-1-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1350907471-2236-1-git-send-email-elezegarcia@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On 10/22/2012 04:04 PM, Ezequiel Garcia wrote:
> When freeing objects, the slob allocator currently free empty pages
> calling __free_pages(). However, page-size kmallocs are disposed
> using put_page() instead.
> 
> It makes no sense to call put_page() for kernel pages that are provided
> by the object allocator, so we shouldn't be doing this ourselves.
> 
> This is based on:
> commit d9b7f22623b5fa9cc189581dcdfb2ac605933bf4
> Author: Glauber Costa <glommer@parallels.com>
Acked-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
