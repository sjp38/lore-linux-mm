Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id CCB186B0073
	for <linux-mm@kvack.org>; Fri, 16 May 2014 11:06:02 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id x13so4491504qcv.33
        for <linux-mm@kvack.org>; Fri, 16 May 2014 08:06:02 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id h65si4349448qge.25.2014.05.16.08.06.01
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 08:06:02 -0700 (PDT)
Date: Fri, 16 May 2014 10:05:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 1/3] slub: keep full slabs on list for per memcg
 caches
In-Reply-To: <20140516130629.GE32113@esperanza>
Message-ID: <alpine.DEB.2.10.1405161003250.32249@gentwo.org>
References: <cover.1399982635.git.vdavydov@parallels.com> <bc70b480221f7765926c8b4d63c55fb42e85baaf.1399982635.git.vdavydov@parallels.com> <alpine.DEB.2.10.1405141114040.16512@gentwo.org> <20140515063441.GA32113@esperanza> <alpine.DEB.2.10.1405151011210.24665@gentwo.org>
 <20140516130629.GE32113@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 16 May 2014, Vladimir Davydov wrote:

> But w/o ref-counting how can we make sure that all kfrees to the cache
> we are going to re-parent have been completed so that it can be safely
> destroyed? An example:

Keep the old structure around until the counter of slabs (partial, full)
of that old structure is zero? Move individual slab pages until you reach
zero.

One can lock out frees by setting c->page = NULL, zapping the partial list
and taking the per node list lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
