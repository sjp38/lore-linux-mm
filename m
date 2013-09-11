Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 4611A6B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 10:35:27 -0400 (EDT)
Date: Wed, 11 Sep 2013 14:35:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 06/16] slab: put forward freeing slab management object
In-Reply-To: <1377161065-30552-7-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <000001410d72beda-2c38b76c-3962-45fc-9d16-99452dbd7edc-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-7-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Aug 2013, Joonsoo Kim wrote:

> We don't need to free slab management object in rcu context,
> because, from now on, we don't manage this slab anymore.
> So put forward freeing.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
