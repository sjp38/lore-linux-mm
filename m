Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABBA6B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:39:35 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t10-v6so13741975plr.12
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:39:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r3si12263979pfe.147.2018.03.26.14.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 14:39:34 -0700 (PDT)
Date: Mon, 26 Mar 2018 14:39:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHSET] mm, memcontrol: Implement memory.swap.events
Message-Id: <20180326143931.41a15320fd4d4af26c86d42e@linux-foundation.org>
In-Reply-To: <20180324165127.701194-1-tj@kernel.org>
References: <20180324165127.701194-1-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com, guro@fb.com, riel@surriel.com, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sat, 24 Mar 2018 09:51:25 -0700 Tejun Heo <tj@kernel.org> wrote:

> This patchset implements memory.swap.events which contains max and
> fail events so that userland can monitor and respond to swap running
> out.  It contains the following two patches.
> 
>  0001-mm-memcontrol-Move-swap-charge-handling-into-get_swa.patch
>  0002-mm-memcontrol-Implement-memory.swap.events.patch
> 
> This patchset is on top of the "cgroup/for-4.17: Make cgroup_rstat
> available to controllers" patchset[1] and "mm, memcontrol: Make
> cgroup_rstat available to controllers" patchset[2] and also available
> in the following git branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-memcg-swap.events

This doesn't appear to be in linux-next yet.  It should be by now if it's
targeted at 4.17?
