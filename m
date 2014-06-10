Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC616B00ED
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 10:26:24 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so2725463qae.5
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 07:26:23 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id o6si956950qah.127.2014.06.10.07.26.23
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 07:26:23 -0700 (PDT)
Date: Tue, 10 Jun 2014 09:26:19 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm v2 8/8] slab: make dead memcg caches discard free
 slabs immediately
In-Reply-To: <20140610100313.GA6293@esperanza>
Message-ID: <alpine.DEB.2.10.1406100925270.17142@gentwo.org>
References: <cover.1402060096.git.vdavydov@parallels.com> <27a202c6084d6bb19cc3e417793f05104b908ded.1402060096.git.vdavydov@parallels.com> <20140610074317.GE19036@js1304-P5Q-DELUXE> <20140610100313.GA6293@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 10 Jun 2014, Vladimir Davydov wrote:

> Frankly, I incline to shrinking dead SLAB caches periodically from
> cache_reap too, because it looks neater and less intrusive to me. Also
> it has zero performance impact, which is nice.
>
> However, Christoph proposed to disable per cpu arrays for dead caches,
> similarly to SLUB, and I decided to give it a try, just to see the end
> code we'd have with it.
>
> I'm still not quite sure which way we should choose though...

Which one is cleaner?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
