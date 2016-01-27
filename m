Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id BB4A46B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 12:55:29 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id d63so10564384ioj.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:55:29 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id me4si12894654igb.100.2016.01.27.09.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 09:55:29 -0800 (PST)
Date: Wed, 27 Jan 2016 11:55:27 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 16/16] mm/slab: introduce new slab management type,
 OBJFREELIST_SLAB
In-Reply-To: <56A8FBE4.1060806@suse.cz>
Message-ID: <alpine.DEB.2.20.1601271154310.14468@east.gentwo.org>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com> <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com> <56A8C788.9000004@suse.cz> <alpine.DEB.2.20.1601271047480.14468@east.gentwo.org> <56A8FBE4.1060806@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 27 Jan 2016, Vlastimil Babka wrote:

> OK. Perhaps a LSF/MM topic then to discuss whether we need both? What are the
> remaining cases where SLAB is better choice, and can there be something done
> about them in SLUB?

Right now one is driving the other which is good I think. So you may just
ignore my cynical comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
