Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id F302C6B0259
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:28:16 -0400 (EDT)
Received: by iofh134 with SMTP id h134so180984857iof.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 09:28:16 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id c32si12933937iod.141.2015.09.28.09.28.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 28 Sep 2015 09:28:16 -0700 (PDT)
Date: Mon, 28 Sep 2015 11:28:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 5/7] slub: support for bulk free with SLUB freelists
In-Reply-To: <20150928175114.07e85114@redhat.com>
Message-ID: <alpine.DEB.2.20.1509281113400.30876@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon> <20150928122629.15409.69466.stgit@canyon> <alpine.DEB.2.20.1509281011250.30332@east.gentwo.org> <20150928175114.07e85114@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:

> > Do you really need separate parameters for freelist_head? If you just want
> > to deal with one object pass it as freelist_head and set cnt = 1?
>
> Yes, I need it.  We need to know both the head and tail of the list to
> splice it.

Ok so this is to avoid having to scan the list to its end? x is the end
of the list and freelist_head the beginning. That is weird.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
