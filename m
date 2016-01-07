Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id DEEC2828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 09:44:48 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id u188so101177167wmu.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 06:44:48 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id dh8si111762469wjb.102.2016.01.07.06.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 06:44:47 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id f206so100529549wmf.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 06:44:47 -0800 (PST)
Date: Thu, 7 Jan 2016 15:44:46 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 1/4] drm: add support for generic zpos property
Message-ID: <20160107144446.GS8076@phenom.ffwll.local>
References: <1451998373-13708-1-git-send-email-m.szyprowski@samsung.com>
 <1451998373-13708-2-git-send-email-m.szyprowski@samsung.com>
 <20160107135922.GO8076@phenom.ffwll.local>
 <568E7740.8090709@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <568E7740.8090709@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: intel-gfx@lists.freedesktop.org, Linux MM <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <jens.axboe@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Jan 07, 2016 at 03:33:36PM +0100, Marek Szyprowski wrote:
> Hello,
> 
> On 2016-01-07 14:59, Daniel Vetter wrote:
> >On Tue, Jan 05, 2016 at 01:52:50PM +0100, Marek Szyprowski wrote:
> >>This patch adds support for generic plane's zpos property property with
> >>well-defined semantics:
> >>- added zpos properties to drm core and plane state structures
> >>- added helpers for normalizing zpos properties of given set of planes
> >>- well defined semantics: planes are sorted by zpos values and then plane
> >>   id value if zpos equals
> >>
> >>Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> >lgtm I think. Longer-term we want to think whether we don't want to
> >extract such extensions into separate files, and push the kerneldoc into
> >an overview DOC: section in there. Just to keep things more closely
> >together. Benjamin with drm/sti also needs this, so cc'ing him.
> 
> Besides sti and exynos, zpos is also already implemented in rcar, mdp5 and
> omap
> drivers. I'm not sure what should be done in case of omap, which uses this
> property
> with different name ("zorder" instead of "zpos").

Argh, it escaped badly already :( Wrt omap I'd just leave it be (atomic
conversion should maybe try to get rid of it though), but for everyone
else it would indeed be nice if the could convert over ... Mostly it
should boil down to removing/replacing code to register the prop, and
looking at the new core one to figure out what to do.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
