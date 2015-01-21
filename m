Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id E911B6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 17:44:52 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id tr6so14834646ieb.4
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 14:44:52 -0800 (PST)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id bc8si510009igb.36.2015.01.21.14.44.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 14:44:51 -0800 (PST)
Received: by mail-ie0-f180.google.com with SMTP id rl12so10766329iec.11
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 14:44:51 -0800 (PST)
Date: Wed, 21 Jan 2015 14:44:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: move MACRO SLAB_NEVER_MERGE and SLAB_MERGE_SAME to
 file linux/slab.h
In-Reply-To: <CAC2pzGd_p37Pi53ZEQShMj9BAECPXZCsxQwm=kKLACwmSBB99w@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1501211443410.2716@chino.kir.corp.google.com>
References: <CAC2pzGe9Q+19LpyFPwr8+TZ02XfCqwrQzsEsJA8WWB6XhuJyeQ@mail.gmail.com> <alpine.DEB.2.11.1501062114240.5674@gentwo.org> <CAC2pzGd_p37Pi53ZEQShMj9BAECPXZCsxQwm=kKLACwmSBB99w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bryton Lee <brytonlee01@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, iamjoonsoo.kim@lge.com, penberg@kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 7 Jan 2015, Bryton Lee wrote:

> thanks for review my patch.
> 
> I want to move these macros to linux/slab.h cause I don't want perform
> merge in slab level.   for example. ss read /proc/slabinfo to finger out
> how many requests pending in the TCP listern queue.  it  use slabe name
> "tcp_timewait_sock_ops" search in /proc/slabinfo, although the name is
> obsolete. so I committed other patch  to iproute2, replaced
> tcp_timewait_sock_ops by request_sock_TCP, but it still not work, because
> slab request_sock_TCP  merge into kmalloc-256.
> 
> how could I prevent this merge happen.  I'm new to kernel, this is my first
> time submit a kernel patch, thanks!
> 

Any bit in SLAB_NEVER_MERGE will cause the allocator to not merge the slab 
caches, it's not necessary to all of them be set as it seems you're 
implying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
