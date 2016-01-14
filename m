Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 26404828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 12:13:19 -0500 (EST)
Received: by mail-io0-f174.google.com with SMTP id 1so412755627ion.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 09:13:19 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id i4si50582876igm.1.2016.01.14.09.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 09:13:18 -0800 (PST)
Date: Thu, 14 Jan 2016 11:13:17 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 09/16] mm/slab: put the freelist at the end of slab
 page
In-Reply-To: <1452749069-15334-10-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1601141108060.4629@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com> <1452749069-15334-10-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Jan 2016, Joonsoo Kim wrote:

>  /*
>   * Calculate the number of objects and left-over bytes for a given buffer size.
>   */
>  static void cache_estimate(unsigned long gfporder, size_t buffer_size,
> -			   size_t align, int flags, size_t *left_over,
> -			   unsigned int *num)
> +		unsigned long flags, size_t *left_over, unsigned int *num)
>  {

Return the number of objects from the function? Avoid returning values by
reference. left_over is already bad enough.

Otherwise

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
