Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 667D16B0005
	for <linux-mm@kvack.org>; Sat, 23 Apr 2016 07:21:10 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k200so75068302lfg.1
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 04:21:10 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id n9si13679992wjv.201.2016.04.23.04.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Apr 2016 04:21:08 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id e201so10022801wme.2
        for <linux-mm@kvack.org>; Sat, 23 Apr 2016 04:21:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160422144957.64619ee9b19991e4fdf89668@linux-foundation.org>
References: <1460444239-22475-1-git-send-email-chris@chris-wilson.co.uk>
	<CACZ9PQV+H+i11E-GEfFeMD3cXWXOF1yPGJH8j7BLXQVqFB3oGw@mail.gmail.com>
	<20160414134926.GD19990@nuc-i3427.alporthouse.com>
	<CACZ9PQXCHRC5bFqQKmtOv+GyuEmEaXDVPJdQhBt0sXPfomFTNw@mail.gmail.com>
	<20160415111431.GL19990@nuc-i3427.alporthouse.com>
	<20160422144957.64619ee9b19991e4fdf89668@linux-foundation.org>
Date: Sat, 23 Apr 2016 13:21:08 +0200
Message-ID: <CACZ9PQXze0dPHz9vf8o+Cpzv8j__Oe+HBJmv8H=bCNie_x+CyA@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc: Keep a separate lazy-free list
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Toshi Kani <toshi.kani@hp.com>, Shawn Lin <shawn.lin@rock-chips.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Apr 22, 2016 at 11:49 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 15 Apr 2016 12:14:31 +0100 Chris Wilson <chris@chris-wilson.co.uk> wrote:
>
>> > > purge_fragmented_blocks() manages per-cpu lists, so that looks safe
>> > > under its own rcu_read_lock.
>> > >
>> > > Yes, it looks feasible to remove the purge_lock if we can relax sync.
>> >
>> > what is still left is waiting on vmap_area_lock for !sync mode.
>> > but probably is not that bad.
>>
>> Ok, that's bit beyond my comfort zone with a patch to change the free
>> list handling. I'll chicken out for the time being, atm I am more
>> concerned that i915.ko may call set_page_wb() frequently on individual
>> pages.
>
> Nick Piggin's vmap rewrite.  20x (or more) faster.
> https://lwn.net/Articles/285341/
>
> 10 years ago, never finished.

But that's exactly what we are changing making 20.5x faster :)

--
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
