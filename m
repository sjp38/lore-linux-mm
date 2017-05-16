Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 716046B03B3
	for <linux-mm@kvack.org>; Tue, 16 May 2017 07:09:21 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 196so24812839wmk.9
        for <linux-mm@kvack.org>; Tue, 16 May 2017 04:09:21 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id r5si1971761wmf.103.2017.05.16.04.09.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 04:09:20 -0700 (PDT)
Date: Tue, 16 May 2017 12:09:08 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] drm: use kvmalloc_array for drm_malloc*
Message-ID: <20170516110908.GE26693@nuc-i3427.alporthouse.com>
References: <20170516090606.5891-1-mhocko@kernel.org>
 <20170516093119.GW19912@nuc-i3427.alporthouse.com>
 <20170516105352.GH2481@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170516105352.GH2481@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>

On Tue, May 16, 2017 at 12:53:52PM +0200, Michal Hocko wrote:
> On Tue 16-05-17 10:31:19, Chris Wilson wrote:
> > On Tue, May 16, 2017 at 11:06:06AM +0200, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > drm_malloc* has grown their own kmalloc with vmalloc fallback
> > > implementations. MM has grown kvmalloc* helpers in the meantime. Let's
> > > use those because it a) reduces the code and b) MM has a better idea
> > > how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
> > > with __GFP_NORETRY).
> > 
> > Better? The same idea. The only difference I was reluctant to hand out
> > large pages for long lived objects. If that's the wisdom of the core mm,
> > so be it.
> 
> vmalloc tends to fragment physical memory more os it is preferable to
> try the physically contiguous request first and only fall back to
> vmalloc if the first attempt would be too costly or it fails.

Not relevant for the changelog in this patch, but it would be nice to
have that written in kvmalloc() as to why the scatterring of 4k vmapped
pages prevents defragmentation when compared to allocating large pages.
I have vague recollections of seeing the conversation, but a summary as
to the reason why kvmalloc prefers large pages will be good for future
reference.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
