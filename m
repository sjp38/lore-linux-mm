Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7546B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 07:56:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g65so840807pfe.9
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 04:56:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j65si9128944iod.89.2017.10.02.04.56.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 04:56:49 -0700 (PDT)
Subject: Re: [v8 0/4] cgroup-aware OOM killer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz>
	<CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
	<20170927162300.GA5623@castle.DHCP.thefacebook.com>
	<CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
	<CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
In-Reply-To: <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
Message-Id: <201710022056.EJI43796.FSFLOHQJtOVMOF@I-love.SAKURA.ne.jp>
Date: Mon, 2 Oct 2017 20:56:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shakeelb@google.com, thockin@hockin.org
Cc: guro@fb.com, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, kernel-team@fb.com, rientjes@google.com, linux-mm@kvack.org, vdavydov.dev@gmail.com, akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Shakeel Butt wrote:
> I think Tim has given very clear explanation why comparing A & D makes
> perfect sense. However I think the above example, a single user system
> where a user has designed and created the whole hierarchy and then
> attaches different jobs/applications to different nodes in this
> hierarchy, is also a valid scenario. One solution I can think of, to
> cater both scenarios, is to introduce a notion of 'bypass oom' or not
> include a memcg for oom comparision and instead include its children
> in the comparison.

I'm not catching up to this thread because I don't use memcg.
But if there are multiple scenarios, what about offloading memcg OOM
handling to loadable kernel modules (like there are many filesystems
which are called by VFS interface) ? We can do try and error more casually.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
