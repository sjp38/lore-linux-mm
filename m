Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id B5BDA6B00D3
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 12:41:44 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so2089344bkb.26
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 09:41:44 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id w8si5208145bkn.212.2013.11.25.09.41.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 09:41:43 -0800 (PST)
Date: Mon, 25 Nov 2013 12:41:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v11 00/15] kmemcg shrinkers
Message-ID: <20131125174135.GE22729@cmpxchg.org>
References: <cover.1385377616.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1385377616.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, glommer@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

I ran out of steam reviewing these because there were too many things
that should be changed in the first couple patches.

I realize this is frustrating to see these type of complaints in v11
of a patch series, but the review bandwidth was simply exceeded back
when Glauber submitted this along with the kmem accounting patches.  A
lot of the kmemcg commits themselves don't even have review tags or
acks, but it all got merged anyway, and the author has moved on to
different projects...

Too much stuff slips past the only two people that have more than one
usecase on their agenda and are willing to maintain this code base -
which is in desparate need of rework and pushback against even more
drive-by feature dumps.  I have repeatedly asked to split the memcg
tree out of the memory tree to better deal with the vastly different
developmental stages of memcg and the rest of the mm code, to no
avail.  So I don't know what to do anymore, but this is not working.

Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
