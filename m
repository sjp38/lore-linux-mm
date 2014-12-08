Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id A68D56B006E
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 12:08:04 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id tr6so4857475ieb.21
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 09:08:04 -0800 (PST)
Received: from resqmta-po-02v.sys.comcast.net (resqmta-po-02v.sys.comcast.net. [2001:558:fe16:19:96:114:154:161])
        by mx.google.com with ESMTPS id a199si4054257ioa.79.2014.12.08.09.08.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 09:08:03 -0800 (PST)
Date: Mon, 8 Dec 2014 11:08:00 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] memcg: fix possible use-after-free in
 memcg_kmem_get_cache
In-Reply-To: <20141208152905.GA25542@esperanza>
Message-ID: <alpine.DEB.2.11.1412081107100.21477@gentwo.org>
References: <1417969947-4072-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.11.1412080848240.21299@gentwo.org> <20141208152905.GA25542@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 8 Dec 2014, Vladimir Davydov wrote:

> Sounds reasonable, thanks. The updated patch is below.

Ok. SLAB also needs to have a similar hook scheme than SLUB at some point.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
