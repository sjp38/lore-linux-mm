Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6856B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 18:09:50 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u19-v6so46970397qkl.13
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 15:09:50 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x189-v6si11524591qkc.266.2018.07.16.15.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 15:09:48 -0700 (PDT)
Date: Mon, 16 Jul 2018 15:09:21 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
Message-ID: <20180716220918.GA3898@castle.DHCP.thefacebook.com>
References: <20171130152824.1591-1-guro@fb.com>
 <20180605114729.GB19202@dhcp22.suse.cz>
 <alpine.DEB.2.21.1807131438380.194789@chino.kir.corp.google.com>
 <0a86d2a7-b78e-7e69-f628-aa2c75d91ff0@i-love.sakura.ne.jp>
 <0d018c7e-a3de-a23a-3996-bed8b28b1e4a@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <0d018c7e-a3de-a23a-3996-bed8b28b1e4a@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jul 17, 2018 at 06:13:47AM +0900, Tetsuo Handa wrote:
> No response from Roman and David...
> 
> Andrew, will you once drop Roman's cgroup-aware OOM killer and David's patches?
> Roman's series has a bug which I mentioned and which can be avoided by my patch.
> David's patch is using MMF_UNSTABLE incorrectly such that it might start selecting
> next OOM victim without trying to reclaim any memory.
> 
> Since they are not responding to my mail, I suggest once dropping from linux-next.

I was in cc, and didn't thought that you're expecting something from me.

I don't get, why it's necessary to drop the cgroup oom killer to merge your fix?
I'm happy to help with rebasing and everything else.

Thanks,
Roman
