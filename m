Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3A9A76B008C
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 14:00:24 -0400 (EDT)
Date: Mon, 1 Oct 2012 18:00:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slab: Ignore internal flags in cache creation
In-Reply-To: <1349088458-3940-1-git-send-email-glommer@parallels.com>
Message-ID: <0000013a1d7c65d7-e63e5171-d5ea-4464-a5ea-c345d6804c07-000000@email.amazonses.com>
References: <1349088458-3940-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

On Mon, 1 Oct 2012, Glauber Costa wrote:

> [ v2: leave the mask out decision up to the allocators ]

Acked-by: Christoph Lameter <cl@linux.com>

I would prefer that this mask be named appropriately and be defined in all
sl*_def.h files for all allocators.

Name could be SLAB_AVAILABLE_FLAGS or some name that makes more
sense than CACHE_CREATE_MASK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
