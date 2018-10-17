Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 187D16B0007
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 11:38:20 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 4-v6so27938658qtt.22
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 08:38:20 -0700 (PDT)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id k57si955038qvk.16.2018.10.17.08.38.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Oct 2018 08:38:19 -0700 (PDT)
Date: Wed, 17 Oct 2018 15:38:19 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [patch] mm, slab: avoid high-order slab pages when it does not
 reduce waste
In-Reply-To: <8eaaa366-415a-5d72-7720-82468d853efd@suse.cz>
Message-ID: <0100016682ad79b9-b1dafb6b-98e2-4d43-835d-fded2028840d-000000@email.amazonses.com>
References: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com> <20181012151341.286cd91321cdda9b6bde4de9@linux-foundation.org> <0100016679e3c96f-c78df4e2-9ab8-48db-8796-271c4b439f16-000000@email.amazonses.com> <alpine.DEB.2.21.1810151715220.21338@chino.kir.corp.google.com>
 <010001667d7476a2-f91dcf12-5e90-4ade-97e8-9fd651f7bf17-000000@email.amazonses.com> <8eaaa366-415a-5d72-7720-82468d853efd@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 17 Oct 2018, Vlastimil Babka wrote:

> I.e. the benefits vs drawbacks of higher order allocations for SLAB are
> out of scope here. It would be nice if somebody evaluated them, but the
> potential resulting change would be much larger than what concerns this
> patch. But it would arguably also make SLAB more like SLUB, which you
> already questioned at some point...

Well if this leads to more code going into mm/slab_common.c then I would
certainly welcome that.
