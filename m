Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 27AFC6B0037
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 09:57:45 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id r5so4192132qcx.25
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 06:57:44 -0700 (PDT)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id b38si10286207qge.54.2014.06.16.06.57.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 06:57:44 -0700 (PDT)
Received: by mail-qc0-f178.google.com with SMTP id c9so7929702qcz.9
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 06:57:44 -0700 (PDT)
Date: Mon, 16 Jun 2014 09:57:41 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140616135741.GA11542@htj.dyndns.org>
References: <20140611075729.GA4520@dhcp22.suse.cz>
 <1402473624-13827-1-git-send-email-mhocko@suse.cz>
 <1402473624-13827-2-git-send-email-mhocko@suse.cz>
 <20140611153631.GH2878@cmpxchg.org>
 <20140612132207.GA32720@dhcp22.suse.cz>
 <20140612135600.GI2878@cmpxchg.org>
 <20140612142237.GB32720@dhcp22.suse.cz>
 <20140612161733.GC23606@htj.dyndns.org>
 <20140616125915.GB16915@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140616125915.GB16915@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

Hello, Michal.

On Mon, Jun 16, 2014 at 02:59:15PM +0200, Michal Hocko wrote:
> > There sure is a question of how fast userland will move to the new
> > interface. 
> 
> Yeah, I was mostly thinking about those who would need to to bigger
> changes. AFAIR threads will no longer be distributable between groups.

Thread-level granularity should go away no matter what, but this is
completely irrelevant to memcg which can't do per-thread anyway.  For
whatever reason, a user is stuck with thread-level granularity for
controllers which work that way, the user can use the old hierarchies
for them for the time being.

> > is used but I don't think there's any chance of removing the knob.
> > There's a reason why we're introducing a new version of the whole
> > cgroup interface which can co-exist with the existing one after all.
> > If you wanna version memcg interface separately, maybe that'd work but
> > it sounds like a lot of extra hassle for not much gain.
> 
> No, I didn't mean to version the interface. I just wanted to have
> gradual transition for potential soft_limit users.
> 
> Maybe I am misunderstanding something but I thought that new version of
> API will contain all knobs which are not marked .flags = CFTYPE_INSANE
> while the old API will contain all of them.

Nope, some changes don't fit that model.  CFTYPE_ON_ON_DFL is the
opposite.  Knobs marked with the flag only appear on the default
hierarchy (cgroup core internally calls it the default hierarchy as
this is the tree all the controllers are attached to by default).

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
