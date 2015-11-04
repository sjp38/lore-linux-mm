Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1646B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 05:42:43 -0500 (EST)
Received: by wmeg8 with SMTP id g8so37780528wme.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 02:42:42 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id 5si2869845wmw.58.2015.11.04.02.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 02:42:41 -0800 (PST)
Received: by wmeg8 with SMTP id g8so37780016wme.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 02:42:41 -0800 (PST)
Date: Wed, 4 Nov 2015 11:42:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151104104239.GG29607@dhcp22.suse.cz>
References: <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
 <20151023131956.GA15375@dhcp22.suse.cz>
 <20151023.065957.1690815054807881760.davem@davemloft.net>
 <20151026165619.GB2214@cmpxchg.org>
 <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151029161009.GA9160@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 29-10-15 09:10:09, Johannes Weiner wrote:
> On Thu, Oct 29, 2015 at 04:25:46PM +0100, Michal Hocko wrote:
> > On Tue 27-10-15 09:42:27, Johannes Weiner wrote:
[...]
> > > You carefully skipped over this part. We can ignore it for socket
> > > memory but it's something we need to figure out when it comes to slab
> > > accounting and tracking.
> > 
> > I am sorry, I didn't mean to skip this part, I though it would be clear
> > from the previous text. I think kmem accounting falls into the same
> > category. Have a sane default and a global boottime knob to override it
> > for those that think differently - for whatever reason they might have.
> 
> Yes, that makes sense to me.
> 
> Like cgroup.memory=nosocket, would you think it makes sense to include
> slab in the default for functional/semantical completeness and provide
> a cgroup.memory=noslab for powerusers?

I am still not sure whether the kmem accounting is stable enough to be
enabled by default. If for nothing else the allocation failures, which
are not allowed for the global case and easily triggered by the hard
limit, might be a big problem. My last attempts to allow GFP_NOFS to
fail made me quite skeptical. I still believe this is something which
will be solved in the long term but the current state might be still too
fragile. So I would rather be conservative and have the kmem accounting
disabled by default with a config option and boot parameter to override.
If somebody is confident that the desired load is stable then the config
can be enabled easily.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
