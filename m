Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A55066B0069
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 03:25:56 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id fb4so3648104wid.0
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 00:25:56 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id fb15si8105092wid.76.2014.10.06.00.25.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Oct 2014 00:25:55 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id fb4so3628378wid.10
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 00:25:55 -0700 (PDT)
Date: Mon, 6 Oct 2014 09:25:52 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: Kswapd 100% CPU since 3.8 on Sandybridge
Message-ID: <20141006072552.GC26941@phenom.ffwll.local>
References: <CABe+QzA=0YVpQ8rN+3X-cbH6JP1nWTvp2spb93P9PqJhmjBROA@mail.gmail.com>
 <CABe+QzA-E40bFFXYJBc663Kx0KrE3xy2uZq5xOH2XL6mFPA6+w@mail.gmail.com>
 <CABe+QzCn_7xm1x62o5d2VoiQrf_7LorhnVOD905Zzd+uu_EuqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABe+QzCn_7xm1x62o5d2VoiQrf_7LorhnVOD905Zzd+uu_EuqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sarah A Sharp <sarah@thesharps.us>
Cc: linux-mm@kvack.org, mgorman@suse.de, intel-gfx@lists.freedesktop.org

On Sat, Oct 04, 2014 at 10:05:20AM -0700, Sarah A Sharp wrote:
> Please excuse the non-wrapped email. My personal system is currently
> b0rked, so I'm sending this in frustration from my phone.
> 
> My laptop is currently completely hosed. Disk light on full solid
> Mouse movement sluggish to the point of moving a couple cms per second.
> Firefox window greyed out but not OOM killed yet. When this behavior
> occurred in the past, if I ran top, I would see kswapd taking up 100% of
> one of my two CPUs.
> 
> If I can catch the system in time before mouse movement becomes too
> sluggish, closing the browser window will cause kswapd usage to drop, and
> the system goes back to a normal state. If I don't catch it in time, I
> can't even ssh into the box to kill Firefox because the login times out.
> Occasionally Firefox gets OOM killed, but most of the time I have to use
> sysreq keys to reboot the system.
> 
> This can be reproduced by using either Chrome or Firefox. Chrome fails
> faster. I'm not sure whether it's related to loading tabs with a bunch of
> images, maybe flash, but it takes around 10-15 tabs being open before it
> starts to fail. I can try to characterize it further.
> 
> System: Lenovo x220 Intel Sandy Bridge graphics
> Ubuntu 14.04 with edgers PPA for Mesa
> 3.16.3 kernel
> 
> Since around the 3.8 kernel time frame, I've been able to reproduce this
> behavior. I'm pretty sure it was a kernel change.

Hm, doesn't ring any bell for i915 bugs, but to make sure can you please
sample debugfs/dri/0/i915_gem_objects while things go south?

Thanks, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
