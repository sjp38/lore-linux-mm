Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B526E6B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 18:20:01 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id m2-v6so8394429plt.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:20:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r23-v6sor795309pfh.126.2018.07.20.15.20.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 15:20:00 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:19:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <569cf225-f1d3-f81b-5947-cff7bd21381f@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1807201515180.38399@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com> <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com> <9ab77cc7-2167-0659-a2ad-9cec3b9440e9@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807201315580.231119@chino.kir.corp.google.com> <569cf225-f1d3-f81b-5947-cff7bd21381f@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 21 Jul 2018, Tetsuo Handa wrote:

> Why [PATCH 2/2] in https://marc.info/?l=linux-mm&m=153119509215026&w=4 does not
> solve your problem?
> 

Such an invasive patch, and completely rewrites the oom reaper.  I now 
fully understand your frustration with the cgroup aware oom killer being 
merged into -mm without any roadmap to actually being merged.  I agree 
with you that it should be dropped, not sure why it has not been since 
there is no active review on the proposed patchset from four months ago, 
posted twice, that fixes the issues with it, or those patches being merged 
so the damn thing can actually make progress.
