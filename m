Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9FAA46B009D
	for <linux-mm@kvack.org>; Tue, 27 May 2014 10:38:32 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so13873522qge.36
        for <linux-mm@kvack.org>; Tue, 27 May 2014 07:38:32 -0700 (PDT)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id 9si17530481qan.42.2014.05.27.07.38.31
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 07:38:32 -0700 (PDT)
Date: Tue, 27 May 2014 09:38:28 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <20140523195728.GA21344@esperanza>
Message-ID: <alpine.DEB.2.10.1405270937270.14154@gentwo.org>
References: <20140519152437.GB25889@esperanza> <alpine.DEB.2.10.1405191056580.22956@gentwo.org> <537A4D27.1050909@parallels.com> <alpine.DEB.2.10.1405210937440.8038@gentwo.org> <20140521150408.GB23193@esperanza> <alpine.DEB.2.10.1405211912400.4433@gentwo.org>
 <20140522134726.GA3147@esperanza> <alpine.DEB.2.10.1405221422390.15766@gentwo.org> <20140523152642.GD3147@esperanza> <alpine.DEB.2.10.1405231241250.22913@gentwo.org> <20140523195728.GA21344@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 May 2014, Vladimir Davydov wrote:

> > If you look at the end of unfreeze_partials() you see that we release
> > locks and therefore enable preempt before calling into the page allocator.
>
> Yes, we release the node's list_lock before calling discard_slab(), but
> we don't enable irqs, which are disabled in put_cpu_partial(), just
> before calling it, so we call the page allocator with irqs off and
> therefore preemption disabled.

Ok that is something that could be fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
