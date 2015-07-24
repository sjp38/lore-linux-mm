Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8F09003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 04:17:15 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so54670021wic.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 01:17:14 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id m6si2909583wiz.81.2015.07.24.01.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 01:17:13 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so54669097wic.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 01:17:13 -0700 (PDT)
Date: Fri, 24 Jul 2015 10:17:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-ID: <20150724081710.GG4103@dhcp22.suse.cz>
References: <1436958885-18754-2-git-send-email-mhocko@kernel.org>
 <20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
 <20150716071948.GC3077@dhcp22.suse.cz>
 <20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
 <20150716225639.GA11131@cmpxchg.org>
 <20150716160358.de3404c44ba29dc132032bbc@linux-foundation.org>
 <20150717122819.GA14895@cmpxchg.org>
 <20150717151827.GB15934@mtj.duckdns.org>
 <20150717131900.5b0b5d91597d207c474be7a5@linux-foundation.org>
 <20150720114913.GG1211@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150720114913.GG1211@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 20-07-15 13:49:13, Michal Hocko wrote:
> On Fri 17-07-15 13:19:00, Andrew Morton wrote:
[...]
> > Why were cg_proto_flags and cg_proto moved from include/net/sock.h?
> 
> Because they naturally belong to memcg header file. We can keep it there
> if you prefer but I felt like sock.h is quite heavy already.
> Now that I am looking into other MEMCG_KMEM related stuff there,
> memcg_proto_active sounds like a good one to move to memcontrol.h as well.

Double checked and memcg_proto_active has only one user which lives in
memcontrol.c so it doesn't make much sense to have it in the header file
---
