Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4AD86B0069
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 02:27:11 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id l13so45565843itl.0
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 23:27:11 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p1si16387022iop.243.2016.10.05.23.27.10
        for <linux-mm@kvack.org>;
        Wed, 05 Oct 2016 23:27:11 -0700 (PDT)
Date: Thu, 6 Oct 2016 15:27:08 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] slub: move synchronize_sched out of slab_mutex on
 shrink
Message-ID: <20161006062708.GA2525@js1304-P5Q-DELUXE>
References: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
 <0a10d71ecae3db00fb4421bcd3f82bcc911f4be4.1475329751.git.vdavydov.dev@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0a10d71ecae3db00fb4421bcd3f82bcc911f4be4.1475329751.git.vdavydov.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Pekka Enberg <penberg@kernel.org>, Doug Smythies <dsmythies@telus.net>

Ccing Doug, original reporter.

On Sat, Oct 01, 2016 at 04:56:48PM +0300, Vladimir Davydov wrote:
> synchronize_sched() is a heavy operation and calling it per each cache
> owned by a memory cgroup being destroyed may take quite some time. What
> is worse, it's currently called under the slab_mutex, stalling all works
> doing cache creation/destruction.
> 
> Actually, there isn't much point in calling synchronize_sched() for each
> cache - it's enough to call it just once - after setting cpu_partial for
> all caches and before shrinking them. This way, we can also move it out
> of the slab_mutex, which we have to hold for iterating over the slab
> cache list.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=172991
> Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> Reported-by: Doug Smythies <dsmythies@telus.net>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Pekka Enberg <penberg@kernel.org>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

These two patches should be sent to stable. Isn't it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
