Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BFA88E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 05:12:18 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id s50so33388857edd.11
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 02:12:18 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6-v6si2502710ejm.74.2019.01.03.02.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 02:12:17 -0800 (PST)
Date: Thu, 3 Jan 2019 11:12:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] mm: memcontrol: delayed force empty
Message-ID: <20190103101215.GH31793@dhcp22.suse.cz>
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-01-19 04:05:30, Yang Shi wrote:
> 
> Currently, force empty reclaims memory synchronously when writing to
> memory.force_empty.  It may take some time to return and the afterwards
> operations are blocked by it.  Although it can be interrupted by signal,
> it still seems suboptimal.

Why it is suboptimal? We are doing that operation on behalf of the
process requesting it. What should anybody else pay for it? In other
words why should we hide the overhead?

> Now css offline is handled by worker, and the typical usecase of force
> empty is before memcg offline.  So, handling force empty in css offline
> sounds reasonable.

Hmm, so I guess you are talking about
echo 1 > $MEMCG/force_empty
rmdir $MEMCG

and you are complaining that the operation takes too long. Right? Why do
you care actually?
-- 
Michal Hocko
SUSE Labs
