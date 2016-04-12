Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF6D6B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 12:55:48 -0400 (EDT)
Received: by mail-io0-f173.google.com with SMTP id g185so36191197ioa.2
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 09:55:48 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id c129si23526989ioe.176.2016.04.12.09.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 09:55:48 -0700 (PDT)
Date: Tue, 12 Apr 2016 11:55:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 05/11] mm/slab: clean-up kmem_cache_node setup
In-Reply-To: <1460436666-20462-6-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1604121155240.14315@east.gentwo.org>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com> <1460436666-20462-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
