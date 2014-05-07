Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 39FAA6B0038
	for <linux-mm@kvack.org>; Wed,  7 May 2014 10:22:34 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id z60so1133529qgd.9
        for <linux-mm@kvack.org>; Wed, 07 May 2014 07:22:33 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id m17si6814485qgd.119.2014.05.07.07.22.33
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 07:22:33 -0700 (PDT)
Date: Wed, 7 May 2014 09:22:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 02/10] slab: makes clear_obj_pfmemalloc() just return
 masked value
In-Reply-To: <1399442780-28748-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1405070922150.12543@gentwo.org>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com> <1399442780-28748-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Wed, 7 May 2014, Joonsoo Kim wrote:

> clear_obj_pfmemalloc() takes the pointer to pointer to store masked value
> back into this address. But this is useless, since we don't use this stored
> value anymore. All we need is just masked value so makes clear_obj_pfmemalloc()
> just return masked value.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
