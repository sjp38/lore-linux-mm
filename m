Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0F156B03B0
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:53:57 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u12so133298902pgo.4
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:53:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s22si13317801pfg.292.2017.05.16.03.53.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 03:53:56 -0700 (PDT)
Date: Tue, 16 May 2017 12:53:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] drm: use kvmalloc_array for drm_malloc*
Message-ID: <20170516105352.GH2481@dhcp22.suse.cz>
References: <20170516090606.5891-1-mhocko@kernel.org>
 <20170516093119.GW19912@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170516093119.GW19912@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>

On Tue 16-05-17 10:31:19, Chris Wilson wrote:
> On Tue, May 16, 2017 at 11:06:06AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > drm_malloc* has grown their own kmalloc with vmalloc fallback
> > implementations. MM has grown kvmalloc* helpers in the meantime. Let's
> > use those because it a) reduces the code and b) MM has a better idea
> > how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
> > with __GFP_NORETRY).
> 
> Better? The same idea. The only difference I was reluctant to hand out
> large pages for long lived objects. If that's the wisdom of the core mm,
> so be it.

vmalloc tends to fragment physical memory more os it is preferable to
try the physically contiguous request first and only fall back to
vmalloc if the first attempt would be too costly or it fails.

> Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>

thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
