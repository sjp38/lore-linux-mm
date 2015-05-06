Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8476B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 10:30:04 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so10999431pab.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 07:30:03 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id g3si29324085pdo.21.2015.05.06.07.30.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 07:30:03 -0700 (PDT)
Date: Wed, 6 May 2015 17:29:51 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Message-ID: <20150506142951.GC29387@esperanza>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
 <20150506115941.GH14550@dhcp22.suse.cz>
 <20150506122431.GA29387@esperanza>
 <20150506123541.GK14550@dhcp22.suse.cz>
 <20150506132510.GB29387@esperanza>
 <20150506135520.GN14550@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150506135520.GN14550@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 06, 2015 at 03:55:20PM +0200, Michal Hocko wrote:
> On Wed 06-05-15 16:25:10, Vladimir Davydov wrote:
> > On Wed, May 06, 2015 at 02:35:41PM +0200, Michal Hocko wrote:
[...]
> > > NOACCOUNT doesn't imply kmem at all so it is not clear who is in charge
> > > of the accounting.
> > 
> > IMO it is a benefit. If one day for some reason we want to bypass memcg
> > accounting for some other type of allocation somewhere, we can simply
> > reuse it.
> 
> But what if somebody, say a highlevel memory allocator in the kernel,
> want's to (ab)use this flag for its internal purpose as well?

We won't let him :-)

If we take your argument about future (ab)users seriously, we should
also consider what will happen if one wants to use e.g. __GFP_HARDWALL,
which BTW has a generic name too although it's cpuset-specific.

My point is that MEMCG is the only subsystem of the kernel that tries to
do full memory accounting, and there is no point in introducing another
one, because we already have it. So we have full right to reserve
__GFP_NOACCOUNT for our purposes, just like cpuset reserves
__GFP_HARDWALL and kmemcheck __GFP_NOTRACK. Any newcomer must take this
into account.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
