Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD156B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 11:49:07 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id r5so7075808qcx.22
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:49:07 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id m9si25554300qav.68.2014.06.30.08.49.06
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 08:49:06 -0700 (PDT)
Date: Mon, 30 Jun 2014 10:49:03 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm v3 8/8] slab: do not keep free objects/slabs on dead
 memcg caches
In-Reply-To: <20140627060534.GC9511@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1406301048070.19422@gentwo.org>
References: <cover.1402602126.git.vdavydov@parallels.com> <a985aec824cd35df381692fca83f7a8debc80305.1402602126.git.vdavydov@parallels.com> <20140624073840.GC4836@js1304-P5Q-DELUXE> <20140625134545.GB22340@esperanza>
 <20140627060534.GC9511@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 27 Jun 2014, Joonsoo Kim wrote:

> Christoph,
> Is it tolerable result for large scale system? Or do we need to find
> another solution?


The overhead is pretty intense but then this is a rare event I guess?

It seems that it is much easier on the code and much faster to do the
periodic reaping. Why not simply go with that?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
