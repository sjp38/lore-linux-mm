Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 80C9B6B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:17:09 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id 63so9640560qgz.19
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 08:17:09 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id 68si8361697qgn.64.2014.04.15.08.17.08
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 08:17:08 -0700 (PDT)
Date: Tue, 15 Apr 2014 10:17:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm 1/4] memcg, slab: do not schedule cache destruction
 when last page goes away
In-Reply-To: <534CD08F.30702@parallels.com>
Message-ID: <alpine.DEB.2.10.1404151016400.11231@gentwo.org>
References: <cover.1397054470.git.vdavydov@parallels.com> <8ea8b57d5264f16ee33497a4317240648645704a.1397054470.git.vdavydov@parallels.com> <20140415021614.GC7969@cmpxchg.org> <534CD08F.30702@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, mhocko@suse.cz, glommer@gmail.com, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Tue, 15 Apr 2014, Vladimir Davydov wrote:

> 2) When freeing an object of a dead memcg cache, initiate thorough check
> if the cache is really empty and destroy it then. That could be
> implemented by poking the reaping thread on kfree, and actually does not
> require the schedule_work in memcg_release_pages IMO.

There is already logic in both slub and slab that does that on cache
close.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
