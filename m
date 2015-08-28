Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 98CDC6B0255
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:14:41 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so24845543wic.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:14:41 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id hf9si6577396wib.39.2015.08.28.10.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 10:14:40 -0700 (PDT)
Received: by wiae7 with SMTP id e7so2943087wia.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:14:39 -0700 (PDT)
Date: Fri, 28 Aug 2015 19:14:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Message-ID: <20150828171438.GD21463@dhcp22.suse.cz>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-5-git-send-email-tj@kernel.org>
 <20150828164918.GJ9610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828164918.GJ9610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri 28-08-15 19:49:18, Vladimir Davydov wrote:
> On Fri, Aug 28, 2015 at 11:25:30AM -0400, Tejun Heo wrote:
> > On the default hierarchy, all memory consumption will be accounted
> > together and controlled by the same set of limits.  Always enable
> > kmemcg on the default hierarchy.
> 
> IMO we should introduce a boot time knob for disabling it, because kmem
> accounting is still not perfect, besides some users might prefer to go
> w/o it for performance reasons.

I would even argue for opt-in rather than opt-out.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
