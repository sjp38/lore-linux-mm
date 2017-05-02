Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00D5B6B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:04:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q91so14142205wrb.8
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:04:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j80si2699161wmj.45.2017.05.02.07.04.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 07:04:00 -0700 (PDT)
Date: Tue, 2 May 2017 16:03:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] mm/memcontrol: fix reclaim bugs in mem_cgroup_iter
Message-ID: <20170502140357.GL14593@dhcp22.suse.cz>
References: <1493416547-19212-1-git-send-email-sean.j.christopherson@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493416547-19212-1-git-send-email-sean.j.christopherson@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri 28-04-17 14:55:45, Sean Christopherson wrote:
> This patch set contains two bug fixes for mem_cgroup_iter().  The bugs
> were found by code inspection and were confirmed via synthetic testing
> that forcefully setup the failing conditions.

I assume that you added some artificial sleeps to make those races more
probable, right? Or did you manage to hit those issue solely from the
userspace? I will have a look at those patches. It has been some time
since I've had it cached. It is pretty subtle code so I would like to
understand the urgency before I dive into this further.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
