Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 924666B0254
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 11:22:53 -0400 (EDT)
Received: by iofb144 with SMTP id b144so179455194iof.1
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:22:53 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id w7si10902261iod.51.2015.09.28.08.22.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 28 Sep 2015 08:22:52 -0700 (PDT)
Date: Mon, 28 Sep 2015 10:22:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 6/7] slub: optimize bulk slowpath free by detached
 freelist
In-Reply-To: <20150928122634.15409.6956.stgit@canyon>
Message-ID: <alpine.DEB.2.20.1509281017300.30332@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon> <20150928122634.15409.6956.stgit@canyon>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
