Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6A09C6B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 10:47:04 -0400 (EDT)
Received: by wgin8 with SMTP id n8so14323042wgi.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 07:47:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ho2si4230874wjb.162.2015.05.06.07.47.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 07:47:03 -0700 (PDT)
Date: Wed, 6 May 2015 16:46:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Message-ID: <20150506144659.GO14550@dhcp22.suse.cz>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
 <20150506115941.GH14550@dhcp22.suse.cz>
 <20150506122431.GA29387@esperanza>
 <20150506123541.GK14550@dhcp22.suse.cz>
 <20150506132510.GB29387@esperanza>
 <20150506135520.GN14550@dhcp22.suse.cz>
 <20150506142951.GC29387@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150506142951.GC29387@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 06-05-15 17:29:51, Vladimir Davydov wrote:
[...]
> My point is that MEMCG is the only subsystem of the kernel that tries to
> do full memory accounting, and there is no point in introducing another
> one, because we already have it.

Then I really do not get why the gfp flag cannot be specific about that.
Anyway, it doesn't really make much sense to bikeshed about the flag
here. So if both you and Johannes agree on the name I will not stand in
the way. I will go and check into include/linux/gfp.h anytime I will try
to remember the flag name...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
