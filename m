Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2616B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 19:00:20 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y18so5329773wrh.12
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 16:00:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c78si1594673wmd.78.2018.01.25.16.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 16:00:19 -0800 (PST)
Date: Thu, 25 Jan 2018 16:00:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
Message-Id: <20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 25 Jan 2018 15:53:48 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> Now that each mem cgroup on the system has a memory.oom_policy tunable to
> specify oom kill selection behavior, remove the needless "groupoom" mount
> option that requires (1) the entire system to be forced, perhaps
> unnecessarily, perhaps unexpectedly, into a single oom policy that
> differs from the traditional per process selection, and (2) a remount to
> change.
> 
> Instead of enabling the cgroup aware oom killer with the "groupoom" mount
> option, set the mem cgroup subtree's memory.oom_policy to "cgroup".

Can we retain the groupoom mount option and use its setting to set the
initial value of every memory.oom_policy?  That way the mount option
remains somewhat useful and we're back-compatible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
