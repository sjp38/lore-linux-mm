Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 484106B0038
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:17:36 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id i50so10939944qgf.3
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:17:36 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id g7si17743700qgd.86.2014.06.02.08.17.35
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 08:17:35 -0700 (PDT)
Date: Mon, 2 Jun 2014 10:17:32 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 7/8] slub: make dead caches discard free slabs
 immediately
In-Reply-To: <CAAmzW4P=kUAJwozBPPos+uUewzSDnE43P6NcGYKNpBjjfv1EWA@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1406021017141.2987@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <5d2fbc894a2c62597e7196bb1ebb8357b15529ab.1401457502.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405300955120.11943@gentwo.org> <20140531110456.GC25076@esperanza> <20140602042435.GA17964@js1304-P5Q-DELUXE>
 <20140602114741.GA1039@esperanza> <CAAmzW4P=kUAJwozBPPos+uUewzSDnE43P6NcGYKNpBjjfv1EWA@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, 2 Jun 2014, Joonsoo Kim wrote:

> Hmm... this is also a bit ugly.
> How about following change?

That looks much cleaner.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
