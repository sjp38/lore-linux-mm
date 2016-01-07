Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1AAB8828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 12:41:37 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id o11so333107716qge.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 09:41:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c134si4806949qkb.124.2016.01.07.09.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 09:41:36 -0800 (PST)
Date: Thu, 7 Jan 2016 18:41:30 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 01/10] slub: cleanup code for kmem cgroup support to
 kmem_cache_free_bulk
Message-ID: <20160107184130.22987ca1@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1601070953460.28564@east.gentwo.org>
References: <20160107140253.28907.5469.stgit@firesoul>
	<20160107140338.28907.48580.stgit@firesoul>
	<alpine.DEB.2.20.1601070953460.28564@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, brouer@redhat.com

On Thu, 7 Jan 2016 09:54:24 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 7 Jan 2016, Jesper Dangaard Brouer wrote:
> 
> > +	/* Support for memcg, compiler can optimize this out */
> > +	*s = cache_from_obj(*s, object);
> > +
> 
> Well the indirection on *s presumably cannot be optimized out. And the
> indirection is not needed when cgroups are not active.

The indirection is optimized out, because build_detached_freelist is
inlined (and I marked it so for readability (even-though it was getting
inlined before by GCC)).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
