Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id AE89C6B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 13:53:01 -0400 (EDT)
Date: Thu, 22 Aug 2013 17:53:00 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 05/16] slab: remove cachep in struct slab_rcu
In-Reply-To: <1377161065-30552-6-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000140a72870a6-f7c87696-ecbc-432c-9f41-93f414c0c623-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-6-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> We can get cachep using page in struct slab_rcu, so remove it.

Ok but this means that we need to touch struct page. Additional cacheline
in cache footprint.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
