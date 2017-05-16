Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B882E6B02EE
	for <linux-mm@kvack.org>; Tue, 16 May 2017 09:21:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c6so124896007pfj.5
        for <linux-mm@kvack.org>; Tue, 16 May 2017 06:21:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k29si13678694pfk.327.2017.05.16.06.21.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 06:21:34 -0700 (PDT)
Date: Tue, 16 May 2017 15:21:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] drm: use kvmalloc_array for drm_malloc*
Message-ID: <20170516132132.GJ2481@dhcp22.suse.cz>
References: <20170516090606.5891-1-mhocko@kernel.org>
 <20170516092230.pzadndxm5gq4i4h6@phenom.ffwll.local>
 <20170516095254.GG2481@dhcp22.suse.cz>
 <20170516130856.hvq62uuq6wmnhvpg@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170516130856.hvq62uuq6wmnhvpg@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>

On Tue 16-05-17 15:08:56, Daniel Vetter wrote:
> On Tue, May 16, 2017 at 11:52:55AM +0200, Michal Hocko wrote:
> > On Tue 16-05-17 11:22:30, Daniel Vetter wrote:
> > > On Tue, May 16, 2017 at 11:06:06AM +0200, Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > drm_malloc* has grown their own kmalloc with vmalloc fallback
> > > > implementations. MM has grown kvmalloc* helpers in the meantime. Let's
> > > > use those because it a) reduces the code and b) MM has a better idea
> > > > how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
> > > > with __GFP_NORETRY).
> > > > 
> > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > 
> > > Shouldn't we go one step further and just remove these wrappers, maybe
> > > with cocci?
> > 
> > my cocci sucks...
> > 
> > > Especially drm_malloc_gfp is surpremely pointless after this
> > > patch (and drm_malloc_ab probably not that useful either).
> > 
> > So what about the following instead? It passes allyesconfig compilation.
> 
> Yeah, looks good, but perhaps rebased onto your first patch. That way we
> split the functional change from the refactor (not the first time innocent
> looking changes in i915 gem code resulted in surprises).

OK, I will split it.

> Your patch also seems to need some stuff from -rc1, and atm drm-misc is
> still pre-rc1, so I'll pull both patches in once that's sorted (I can do
> the rebase myself, since it's rather trivial). But pls remind me in case
> it falls through the cracks and isn't in linux-next by end of this week
> :-)

I have based it on top of the current linux next (next-20170516). Let me
know if other tree is more appropriate.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
