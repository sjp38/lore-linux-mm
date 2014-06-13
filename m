Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF8C6B0031
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 12:34:42 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id o8so4373782qcw.3
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:34:42 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id r2si5125446qat.30.2014.06.13.09.34.41
        for <linux-mm@kvack.org>;
        Fri, 13 Jun 2014 09:34:42 -0700 (PDT)
Date: Fri, 13 Jun 2014 11:34:39 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm v2 8/8] slab: make dead memcg caches discard free
 slabs immediately
In-Reply-To: <20140612065345.GD19918@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.10.1406131133380.913@gentwo.org>
References: <cover.1402060096.git.vdavydov@parallels.com> <27a202c6084d6bb19cc3e417793f05104b908ded.1402060096.git.vdavydov@parallels.com> <20140610074317.GE19036@js1304-P5Q-DELUXE> <20140610100313.GA6293@esperanza> <alpine.DEB.2.10.1406100925270.17142@gentwo.org>
 <20140610151830.GA8692@esperanza> <20140611212431.GA16589@esperanza> <20140612065345.GD19918@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 Jun 2014, Joonsoo Kim wrote:

> BTW, I have a question about cache_reap(). If there are many kmemcg
> users, we would have a lot of slab caches and just to traverse slab
> cache list could take some times. Is it no problem?

Its a big problem and one of the reasons that SLUB was developed. Cache
reaping caused noticable random delays to processing which was
significantly impacting HPC loads of SGI.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
