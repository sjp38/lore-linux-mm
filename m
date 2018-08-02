Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04E6A6B0005
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 14:48:30 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id k10-v6so2040712ybp.7
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 11:48:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j15-v6sor584615ybp.194.2018.08.02.11.48.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 11:48:28 -0700 (PDT)
Date: Thu, 2 Aug 2018 11:48:25 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 3/3] mm, oom: introduce memory.oom.group
Message-ID: <20180802184825.GU1206094@devbig004.ftw2.facebook.com>
References: <20180802003201.817-1-guro@fb.com>
 <20180802003201.817-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180802003201.817-4-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, Aug 01, 2018 at 05:32:01PM -0700, Roman Gushchin wrote:
> For some workloads an intervention from the OOM killer
> can be painful. Killing a random task can bring
> the workload into an inconsistent state.

For patches 1-3,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
