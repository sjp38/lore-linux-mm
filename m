Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 54C986B008A
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 10:07:22 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id f12so5320406qad.14
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 07:07:22 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id hd10si1693119qcb.38.2014.12.12.07.07.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 07:07:21 -0800 (PST)
Date: Fri, 12 Dec 2014 09:07:18 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] memcg: zap memcg_slab_caches and memcg_slab_mutex
In-Reply-To: <1418388362-11221-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1412120906540.6272@gentwo.org>
References: <1418388362-11221-1-git-send-email-vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


As far as I can see for the slab_common.c part this is ok

Acked-by: Christoph Lameter <cl@linux.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
