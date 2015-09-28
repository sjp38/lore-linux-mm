Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 141B86B0038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 09:49:17 -0400 (EDT)
Received: by ioii196 with SMTP id i196so175996631ioi.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 06:49:16 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id p19si11653319igs.100.2015.09.28.06.49.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 28 Sep 2015 06:49:16 -0700 (PDT)
Date: Mon, 28 Sep 2015 08:49:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/7] slub: mark the dangling ifdef #else of
 CONFIG_SLUB_DEBUG
In-Reply-To: <20150928122619.15409.68763.stgit@canyon>
Message-ID: <alpine.DEB.2.20.1509280849020.23642@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon> <20150928122619.15409.68763.stgit@canyon>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:

> The #ifdef of CONFIG_SLUB_DEBUG is located very far from
> the associated #else.  For readability mark it with a comment.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
