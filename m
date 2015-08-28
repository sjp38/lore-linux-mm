Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 933786B0254
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:41:43 -0400 (EDT)
Received: by ykek5 with SMTP id k5so8791361yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:41:43 -0700 (PDT)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id l22si4512219ywe.105.2015.08.28.10.41.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 10:41:42 -0700 (PDT)
Received: by ykay144 with SMTP id y144so7320583yka.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:41:42 -0700 (PDT)
Date: Fri, 28 Aug 2015 13:41:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150828174140.GN26785@mtj.duckdns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
 <20150828171438.GD21463@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828171438.GD21463@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Aug 28, 2015 at 07:14:38PM +0200, Michal Hocko wrote:
> On Fri 28-08-15 19:49:18, Vladimir Davydov wrote:
> > On Fri, Aug 28, 2015 at 11:25:30AM -0400, Tejun Heo wrote:
> > > On the default hierarchy, all memory consumption will be accounted
> > > together and controlled by the same set of limits.  Always enable
> > > kmemcg on the default hierarchy.
> > 
> > IMO we should introduce a boot time knob for disabling it, because kmem
> > accounting is still not perfect, besides some users might prefer to go
> > w/o it for performance reasons.
> 
> I would even argue for opt-in rather than opt-out.

Definitely not.  We wanna put all memory consumptions under the same
roof by default.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
