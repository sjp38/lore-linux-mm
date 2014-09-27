Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC476B0038
	for <linux-mm@kvack.org>; Sat, 27 Sep 2014 11:53:46 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id a13so2190454igq.3
        for <linux-mm@kvack.org>; Sat, 27 Sep 2014 08:53:46 -0700 (PDT)
Received: from resqmta-po-02v.sys.comcast.net (resqmta-po-02v.sys.comcast.net. [2001:558:fe16:19:96:114:154:161])
        by mx.google.com with ESMTPS id e3si5666997igl.1.2014.09.27.08.53.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 27 Sep 2014 08:53:45 -0700 (PDT)
Date: Sat, 27 Sep 2014 10:53:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slab: use IS_ENABLED() instead of ZONE_DMA_FLAG
In-Reply-To: <1411811803.15241.50.camel@x220>
Message-ID: <alpine.DEB.2.11.1409271053170.22114@gentwo.org>
References: <1411667851.2020.6.camel@x41> <20140925185047.GA21089@cmpxchg.org> <1411811803.15241.50.camel@x220>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 27 Sep 2014, Paul Bolle wrote:

> Do your comments require the patch to be redone (partially or entirely)?
> In that case someone else should probably take it and improve it, as I
> hardly understand the issues you raise. Or is the patch already queued
> somewhere, with Cristoph's Ack attached?

Please respin the patch taking Johannes feedback into consideration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
