Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F15C6B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:40:46 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b140so14103185wme.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:40:46 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id o125si14071471wmg.18.2017.03.06.02.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:40:45 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id z63so10786853wmg.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:40:44 -0800 (PST)
Date: Mon, 6 Mar 2017 11:40:41 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
Message-ID: <20170306104041.zghsicrnadoap7lp@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <20170303132949.GC31582@dhcp22.suse.cz>
 <cf383b9b-3cbc-0092-a071-f120874c053c@redhat.com>
 <20170306074258.GA27953@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306074258.GA27953@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org

On Mon, Mar 06, 2017 at 08:42:59AM +0100, Michal Hocko wrote:
> On Fri 03-03-17 09:37:55, Laura Abbott wrote:
> > On 03/03/2017 05:29 AM, Michal Hocko wrote:
> > > On Thu 02-03-17 13:44:32, Laura Abbott wrote:
> > >> Hi,
> > >>
> > >> There's been some recent discussions[1] about Ion-like frameworks. There's
> > >> apparently interest in just keeping Ion since it works reasonablly well.
> > >> This series does what should be the final clean ups for it to possibly be
> > >> moved out of staging.
> > >>
> > >> This includes the following:
> > >> - Some general clean up and removal of features that never got a lot of use
> > >>   as far as I can tell.
> > >> - Fixing up the caching. This is the series I proposed back in December[2]
> > >>   but never heard any feedback on. It will certainly break existing
> > >>   applications that rely on the implicit caching. I'd rather make an effort
> > >>   to move to a model that isn't going directly against the establishement
> > >>   though.
> > >> - Fixing up the platform support. The devicetree approach was never well
> > >>   recieved by DT maintainers. The proposal here is to think of Ion less as
> > >>   specifying requirements and more of a framework for exposing memory to
> > >>   userspace.
> > >> - CMA allocations now happen without the need of a dummy device structure.
> > >>   This fixes a bunch of the reasons why I attempted to add devicetree
> > >>   support before.
> > >>
> > >> I've had problems getting feedback in the past so if I don't hear any major
> > >> objections I'm going to send out with the RFC dropped to be picked up.
> > >> The only reason there isn't a patch to come out of staging is to discuss any
> > >> other changes to the ABI people might want. Once this comes out of staging,
> > >> I really don't want to mess with the ABI.
> > > 
> > > Could you recapitulate concerns preventing the code being merged
> > > normally rather than through the staging tree and how they were
> > > addressed?
> > > 
> > 
> > Sorry, I'm really not understanding your question here, can you
> > clarify?
> 
> There must have been a reason why this code ended up in the staging
> tree, right? So my question is what those reasons were and how they were
> handled in order to move the code from the staging subtree.

No one gave a thing about android in upstream, so Greg KH just dumped it
all into staging/android/. We've discussed ION a bunch of times, recorded
anything we'd like to fix in staging/android/TODO, and Laura's patch
series here addresses a big chunk of that.

This is pretty much the same approach we (gpu folks) used to de-stage the
syncpt stuff.
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
