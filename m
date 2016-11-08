Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA6586B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 18:51:48 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id y126so113700659itb.5
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 15:51:48 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id l2si11276365itc.55.2016.11.08.15.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 15:51:48 -0800 (PST)
Date: Tue, 8 Nov 2016 17:51:46 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 1/2] memcg: Prevent memcg caches to be both OFF_SLAB
 & OBJFREELIST_SLAB
In-Reply-To: <20161107144931.edcf151a04f1af6d230b8a8a@linux-foundation.org>
Message-ID: <alpine.DEB.2.20.1611081750410.22914@east.gentwo.org>
References: <1478553075-120242-1-git-send-email-thgarnie@google.com> <20161107141919.fe50cef419918c7a4660f3c2@linux-foundation.org> <CAJcbSZGO1oVf2cQeCO2_qiUrNdSckhwDSah4sqnnc388J2Rruw@mail.gmail.com>
 <20161107144931.edcf151a04f1af6d230b8a8a@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Garnier <thgarnie@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Mon, 7 Nov 2016, Andrew Morton wrote:

> > I will add more details and send another round.
>
> Please simply send the additional changelog text in this thread -
> processing an entire v4 patch just for a changelog fiddle is rather
> heavyweight.

I think this patch is good for future cleanup. We have had a case here
where an internal flag was passed to kmem_cache_create that caused issues
later. This should not happen. We need to guard against this in the
future.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
