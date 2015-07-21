Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A2D176B0274
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 08:55:50 -0400 (EDT)
Received: by wgkl9 with SMTP id l9so155432027wgk.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 05:55:50 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id p3si18940764wiy.86.2015.07.21.05.55.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 05:55:49 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so113435004wib.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 05:55:48 -0700 (PDT)
Date: Tue, 21 Jul 2015 14:55:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-ID: <20150721125546.GM11967@dhcp22.suse.cz>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
 <1436958885-18754-2-git-send-email-mhocko@kernel.org>
 <20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
 <20150716071948.GC3077@dhcp22.suse.cz>
 <20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
 <20150716225639.GA11131@cmpxchg.org>
 <20150716160358.de3404c44ba29dc132032bbc@linux-foundation.org>
 <20150717122819.GA14895@cmpxchg.org>
 <20150720112356.GF1211@dhcp22.suse.cz>
 <20150720154327.97fd5ca81fe6ce50e4a631ff@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150720154327.97fd5ca81fe6ce50e4a631ff@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 20-07-15 15:43:27, Andrew Morton wrote:
> On Mon, 20 Jul 2015 13:23:56 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> >  I do not think we want two sets of header
> > files - one for mm and other for other external users.
> 
> We're already doing this (mm/*.h) and it works well.

I still fail to see any huge win for memcontrol.h though.
Anyway I gave it a try and hit the dependencies wall very soon
(especially due to mm/slab.h vs. mm/memcontrol.h dependencies). Who
knows how many others are lurking there.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
