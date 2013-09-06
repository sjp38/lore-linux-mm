Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 0FC436B0032
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 11:48:06 -0400 (EDT)
Date: Fri, 6 Sep 2013 15:48:04 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [REPOST PATCH 1/4] slab: factor out calculate nr objects in
 cache_estimate
In-Reply-To: <1378447067-19832-2-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000140f3f56efb-1b2035a6-b81f-433f-aa2d-d1af50018b6a-000000@email.amazonses.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com> <1378447067-19832-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 6 Sep 2013, Joonsoo Kim wrote:

>  	}
>  	*num = nr_objs;
> -	*left_over = slab_size - nr_objs*buffer_size - mgmt_size;
> +	*left_over = slab_size - (nr_objs * buffer_size) - mgmt_size;
>  }

What is the point of this change? Drop it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
