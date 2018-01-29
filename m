Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6826B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 05:47:00 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g13so5390768wrh.19
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 02:47:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l10si9906457wrb.90.2018.01.29.02.46.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 02:46:59 -0800 (PST)
Date: Mon, 29 Jan 2018 11:46:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
Message-ID: <20180129104657.GC21609@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com>
 <20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
 <alpine.DEB.2.10.1801261415090.15318@chino.kir.corp.google.com>
 <20180126143950.719912507bd993d92188877f@linux-foundation.org>
 <alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com>
 <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 26-01-18 16:17:35, Andrew Morton wrote:
> On Fri, 26 Jan 2018 14:52:59 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
[...]
> > Those use cases are also undocumented such that the user doesn't know the 
> > behavior they are opting into.  Nowhere in the patchset does it mention 
> > anything about oom_score_adj other than being oom disabled.  It doesn't 
> > mention that a per-process tunable now depends strictly on whether it is 
> > attached to root or not.  It specifies a fair comparison between the root 
> > mem cgroup and leaf mem cgroups, which is obviously incorrect by the 
> > implementation itself.  So I'm not sure the user would know which use 
> > cases it is valid for, which is why I've been trying to make it generally 
> > purposeful and documented.
> 
> Documentation patches are nice.  We can cc:stable them too, so no huge
> hurry.

What about this?
