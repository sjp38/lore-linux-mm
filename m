Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5688F82966
	for <linux-mm@kvack.org>; Thu, 21 May 2015 18:09:12 -0400 (EDT)
Received: by qcblr10 with SMTP id lr10so566281qcb.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 15:09:12 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id g17si206009qhc.64.2015.05.21.15.09.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 15:09:11 -0700 (PDT)
Received: by qgew3 with SMTP id w3so536060qge.2
        for <linux-mm@kvack.org>; Thu, 21 May 2015 15:09:11 -0700 (PDT)
Date: Thu, 21 May 2015 18:09:08 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150521220908.GJ4914@htj.duckdns.org>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
 <1431978595-12176-4-git-send-email-tj@kernel.org>
 <20150521141225.GB14475@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150521141225.GB14475@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu, May 21, 2015 at 04:12:26PM +0200, Michal Hocko wrote:
> On Mon 18-05-15 15:49:51, Tejun Heo wrote:
> > If move_charge flag is set, memcg tries to move memory charges to the
> > destnation css.  The current implementation migrates memory whenever
> > any thread of a process is migrated making the behavior somewhat
> > arbitrary.  Let's tie memory operations to the threadgroup leader so
> > that memory is migrated only when the leader is migrated.
> > 
> > While this is a behavior change, given the inherent fuziness, this
> > change is not too likely to be noticed and allows us to clearly define
> > who owns the memory (always the leader) and helps the planned atomic
> > multi-process migration.
> > 
> > Signed-off-by: Tejun Heo <tj@kernel.org>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.cz>
> 
> OK, I guess the discussion with Oleg confirmed that the patch is not
> really needed because mm_struct->owner check implies thread group
> leader. This should be sufficient for your purpose Tejun, right?

Hmmm... we still need to update so that it actually iterates leaders
to find the owner as first in taskset == leader assumption is going
away but yeah this patch in itself can go away.  I'll update the next
patch accordingly.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
