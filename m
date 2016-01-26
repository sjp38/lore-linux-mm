Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id DD7036B0258
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:01:33 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id ik10so58505828igb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:01:33 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id b28si5504399ioj.51.2016.01.26.07.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 07:01:33 -0800 (PST)
Date: Tue, 26 Jan 2016 09:01:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/3] Speed up SLUB poisoning + disable checks
In-Reply-To: <20160126070320.GB28254@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.20.1601260900370.27338@east.gentwo.org>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org> <20160126070320.GB28254@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

On Tue, 26 Jan 2016, Joonsoo Kim wrote:

> I doesn't follow up that discussion, but, I think that reusing
> SLAB_POISON for slab sanitization needs more changes. I assume that
> completeness and performance is matter for slab sanitization.
>
> 1) SLAB_POISON isn't applied to specific kmem_cache which has
> constructor or SLAB_DESTROY_BY_RCU flag. For debug, it's not necessary
> to be applied, but, for slab sanitization, it is better to apply it to
> all caches.

Those slabs can be legitimately accessed after the objects were freed. You
cannot sanitize nor poison.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
