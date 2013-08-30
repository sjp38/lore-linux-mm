Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 1E9F66B0075
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:37:55 -0400 (EDT)
Date: Fri, 30 Aug 2013 13:37:54 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/6] slab/block: Add and use kmem_cache_zalloc_node
In-Reply-To: <35769f9779144ace313671235f6508ba683e752b.1377806578.git.joe@perches.com>
Message-ID: <00000140cf71c343-f6cdd204-a553-49b0-bd0b-28492d6d97fe-000000@email.amazonses.com>
References: <cover.1377806578.git.joe@perches.com> <35769f9779144ace313671235f6508ba683e752b.1377806578.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Thu, 29 Aug 2013, Joe Perches wrote:

> Create and use kmem_cache_zalloc_node utility to be
> acompatible style with all the zalloc equivalents
> for kmem_cache_zalloc.

Well I thought more along the lines of dropping the *_zalloc in favor of
__GFP_ZERO but if this is more convenient then I have no objections.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
