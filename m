Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 1DB0E6B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 10:31:53 -0400 (EDT)
Date: Wed, 11 Sep 2013 14:31:51 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/16] slab: change return type of kmem_getpages() to
 struct page
In-Reply-To: <1377161065-30552-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <000001410d6f7625-f84563e7-091f-4a83-b722-3f20d32c5b56-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> It is more understandable that kmem_getpages() return struct page.
> And, with this, we can reduce one translation from virt addr to page and
> makes better code than before. Below is a change of this patch.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
