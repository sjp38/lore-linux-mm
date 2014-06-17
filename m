Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 416CF6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 12:21:02 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id y10so7210205wgg.17
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:21:01 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id es6si13228271wib.105.2014.06.17.09.21.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 09:21:00 -0700 (PDT)
Received: by mail-wi0-f174.google.com with SMTP id bs8so6177751wib.13
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 09:21:00 -0700 (PDT)
Date: Tue, 17 Jun 2014 18:20:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/12] mm: huge_memory: use GFP_TRANSHUGE when charging
 huge pages
Message-ID: <20140617162057.GA9572@dhcp22.suse.cz>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
 <1402948472-8175-4-git-send-email-hannes@cmpxchg.org>
 <20140617134745.GB19886@dhcp22.suse.cz>
 <20140617153018.GA7331@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140617153018.GA7331@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 17-06-14 11:30:18, Johannes Weiner wrote:
[...]
> This first changes __GFP_NORETRY to provide THP-required semantics,
> then switches THP over to it, then fixes oom-disabled/NOFAIL charges.
> 
> Does that make more sense?

Yes. Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
