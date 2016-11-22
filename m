Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9F0E6B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 10:20:40 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id m67so14388285qkf.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 07:20:40 -0800 (PST)
Received: from mail-qt0-f196.google.com (mail-qt0-f196.google.com. [209.85.216.196])
        by mx.google.com with ESMTPS id b124si16642354qkg.291.2016.11.22.07.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 07:20:40 -0800 (PST)
Received: by mail-qt0-f196.google.com with SMTP id n34so2741903qtb.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 07:20:40 -0800 (PST)
Date: Tue, 22 Nov 2016 16:20:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory.force_empty is deprecated
Message-ID: <20161122152037.GA6844@dhcp22.suse.cz>
References: <OF57AEC2D2.FA566D70-ON48258061.002C144F-48258061.002E2E50@notes.na.collabserv.com>
 <20161104152103.GC8825@cmpxchg.org>
 <OF1D622B5E.2C033199-ON4825806E.0032B4F0-4825806E.00382767@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF1D622B5E.2C033199-ON4825806E.0032B4F0-4825806E.00382767@notes.na.collabserv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhao Hui Ding <dingzhh@cn.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Xue Bin Min <minxb@cn.ibm.com>

On Thu 17-11-16 18:13:18, Zhao Hui Ding wrote:
[...]
> We cannot leave it lazily because when new job reuse the cgroup, "cache" 
> doesn't be cleaned automatically.
> We need a mechanism that clean memory.stat.

Could you clarify why, please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
