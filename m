Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E22C26B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 14:29:08 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id o1so244691924ito.7
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 11:29:08 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [69.252.207.35])
        by mx.google.com with ESMTPS id f128si20746332ioe.225.2016.11.07.11.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 11:29:08 -0800 (PST)
Date: Mon, 7 Nov 2016 13:28:09 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] memcg: Prevent memcg caches to be both OFF_SLAB &
 OBJFREELIST_SLAB
In-Reply-To: <CAJcbSZHaN8zVf4_MdpmofNCY719YfRsRq+PjLR-a+M4QGyCnGw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1611071324380.19249@east.gentwo.org>
References: <1477939010-111710-1-git-send-email-thgarnie@google.com> <alpine.DEB.2.10.1610311625430.62482@chino.kir.corp.google.com> <CAJcbSZHic9gfpYHFXySZf=EmUjztBvuHeWWq7CQFi=0Om7OJoA@mail.gmail.com> <alpine.DEB.2.10.1611021744150.110015@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1611031531380.13315@east.gentwo.org> <CAJcbSZHaN8zVf4_MdpmofNCY719YfRsRq+PjLR-a+M4QGyCnGw@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Mon, 7 Nov 2016, Thomas Garnier wrote:

> I am not sure that is possible. kmem_cache_create currently check for
> possible alias, I assume that it goes against what memcg tries to do.

What does aliasing have to do with this? The aliases must have the same
flags otherwise the caches would not have been merged.

> Separate the changes in two patches might make sense:
>
>  1) Fix the original bug by masking the flags passed to create_cache
>  2) Add flags check in kmem_cache_create.
>
> Does it make sense?

Sure.

> > I also want to make sure that there are no other callers that specify
> > extraneou flags while we are at it.
> I will review as many as I can but we might run into surprises (quick
> boot on defconfig didn't show anything). That's why having two
> different patches might be useful.

These surprises can be caught later ... Just make sure that the core works
fine with this. You cannot audit all drivers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
