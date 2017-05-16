Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A47D6B03A8
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:53:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n75so42910248pfh.0
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:53:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si13369964pgq.372.2017.05.16.02.52.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 02:53:00 -0700 (PDT)
Date: Tue, 16 May 2017 11:52:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] drm: use kvmalloc_array for drm_malloc*
Message-ID: <20170516095254.GG2481@dhcp22.suse.cz>
References: <20170516090606.5891-1-mhocko@kernel.org>
 <20170516092230.pzadndxm5gq4i4h6@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170516092230.pzadndxm5gq4i4h6@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>

On Tue 16-05-17 11:22:30, Daniel Vetter wrote:
> On Tue, May 16, 2017 at 11:06:06AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > drm_malloc* has grown their own kmalloc with vmalloc fallback
> > implementations. MM has grown kvmalloc* helpers in the meantime. Let's
> > use those because it a) reduces the code and b) MM has a better idea
> > how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
> > with __GFP_NORETRY).
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Shouldn't we go one step further and just remove these wrappers, maybe
> with cocci?

my cocci sucks...

> Especially drm_malloc_gfp is surpremely pointless after this
> patch (and drm_malloc_ab probably not that useful either).

So what about the following instead? It passes allyesconfig compilation.
---
