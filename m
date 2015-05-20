Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 063196B0121
	for <linux-mm@kvack.org>; Wed, 20 May 2015 10:18:58 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so156761826wic.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 07:18:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vn9si11532498wjc.113.2015.05.20.07.18.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 May 2015 07:18:56 -0700 (PDT)
Date: Wed, 20 May 2015 16:18:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm, memcg: Try charging a page before setting page
 up to date
Message-ID: <20150520141854.GE28678@dhcp22.suse.cz>
References: <1432126245-10908-1-git-send-email-mgorman@suse.de>
 <1432126245-10908-2-git-send-email-mgorman@suse.de>
 <20150520140353.GC28678@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150520140353.GC28678@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux-CGroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-05-15 16:03:53, Michal Hocko wrote:
> I am wondering why do we still have both
> __SetPageUptodate and SetPageUptodate when they are same. Historically
> they were slightly different but this is no longer the case.

Bahh,  I am blind and failed spot a difference game. It is __set_bit vs
set_bit. Sorry about the noise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
