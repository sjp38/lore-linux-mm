Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 1A8FA6B0031
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 11:46:54 -0400 (EDT)
Date: Mon, 1 Jul 2013 15:46:52 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm/slab: Fix drain freelist excessively
In-Reply-To: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <0000013f9aea494f-7a5fe6c7-47d2-42a9-bbe6-5dbc85dab0a5-000000@email.amazonses.com>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 24 Jun 2013, Wanpeng Li wrote:

> The drain_freelist is called to drain slabs_free lists for cache reap,
> cache shrink, memory hotplug callback etc. The tofree parameter is the
> number of slab objects to free instead of the number of slabs to free.

Well its intended to be the number of slabs to free. The patch does not
fix the callers that pass the number of slabs.

I think the best approach would be to fix the callers that pass # of
objects. Make sure they pass # of slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
