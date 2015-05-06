Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 461516B0093
	for <linux-mm@kvack.org>; Wed,  6 May 2015 13:52:30 -0400 (EDT)
Received: by wizk4 with SMTP id k4so212151221wiz.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 10:52:29 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d2si3356390wix.113.2015.05.06.10.52.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 10:52:29 -0700 (PDT)
Date: Wed, 6 May 2015 13:52:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Message-ID: <20150506175212.GA4813@cmpxchg.org>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
 <20150506145814.GP14550@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150506145814.GP14550@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 06, 2015 at 04:58:14PM +0200, Michal Hocko wrote:
> On Tue 05-05-15 12:45:42, Vladimir Davydov wrote:
> [...]
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 97a9373e61e8..37c422df2a0f 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -30,6 +30,7 @@ struct vm_area_struct;
> >  #define ___GFP_HARDWALL		0x20000u
> >  #define ___GFP_THISNODE		0x40000u
> >  #define ___GFP_RECLAIMABLE	0x80000u
> > +#define ___GFP_NOACCOUNT	0x100000u
> >  #define ___GFP_NOTRACK		0x200000u
> >  #define ___GFP_NO_KSWAPD	0x400000u
> >  #define ___GFP_OTHER_NODE	0x800000u
> > @@ -87,6 +88,7 @@ struct vm_area_struct;
> >  #define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL) /* Enforce hardwall cpuset memory allocs */
> >  #define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)/* No fallback, no policies */
> >  #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
> > +#define __GFP_NOACCOUNT	((__force gfp_t)___GFP_NOACCOUNT) /* Don't account to memcg */
> 
> The wording suggests that _any_ memcg charge might be skipped by this flag
> but only kmem part is handled.
>
> So either handle the flag in try_charge or, IMO preferably, update the
> comment here and add WARN_ON{_ONCE}(gfp & __GFP_NOACCOUNT). I do not
> think we should allow to skip the charge for user pages ATM and warning
> could tell us about the abuse of the flag.

Michal, please just stop.

There is no reason to warn the user about this whatsoever.  If you
want to prevent abuse - whatever that means - program your mailreader
to flag patches containing __GFP_NOACCOUNT and review them carefully.

This eagerness to clutter the code with defensiveness against the rest
of the kernel tree and to disrupt the user over every little blip that
has nothing to do with them is really getting old at this point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
