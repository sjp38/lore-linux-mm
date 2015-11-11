Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id BB74D6B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 03:12:15 -0500 (EST)
Received: by wmec201 with SMTP id c201so35805808wme.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 00:12:15 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id p15si11176899wmd.25.2015.11.11.00.12.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 00:12:14 -0800 (PST)
Received: by wmvv187 with SMTP id v187so44223304wmv.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 00:12:14 -0800 (PST)
Date: Wed, 11 Nov 2015 09:12:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151111081212.GA1424@dhcp22.suse.cz>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <20151109140832.GE8916@dhcp22.suse.cz>
 <20151109182840.GJ31308@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151109182840.GJ31308@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 09-11-15 21:28:40, Vladimir Davydov wrote:
> On Mon, Nov 09, 2015 at 03:08:32PM +0100, Michal Hocko wrote:
[...]
> > > Vladimir Davydov (5):
> > >   Revert "kernfs: do not account ino_ida allocations to memcg"
> > >   Revert "gfp: add __GFP_NOACCOUNT"
> > 
> > The patch ordering would break the bisectability. I would simply squash
> 
> How's that? AFAICS the kernel should compile after any first N=1..5
> patches of the series applied.

Sorry, forgot to comment on this. I didn't mean it would break
compilation. It would just reintroduce the bug fixed by "kernfs: do not
account ino_ida allocations to memcg". My understanding is that the bug
is quite unlikely and it will results in a pinned memcg which is much
less serious than a crash or other misbehavior.

I will leave whether this is serious enough to you but as the revert is
basically dropping the flag which can be trivially done in the patch
which renames it and changes its semantic I do not think splitting has
any large advantage.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
