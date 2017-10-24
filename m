Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA396B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 13:54:14 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id c21so3183920wrg.16
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 10:54:14 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u90si602858edc.538.2017.10.24.10.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Oct 2017 10:54:12 -0700 (PDT)
Date: Tue, 24 Oct 2017 13:54:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171024175405.GA4733@cmpxchg.org>
References: <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009202613.GA15027@cmpxchg.org>
 <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
 <20171010141733.GB16710@cmpxchg.org>
 <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz>
 <20171012190312.GA5075@cmpxchg.org>
 <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
 <20171013070001.mglwdzdrqjt47clz@dhcp22.suse.cz>
 <20171013152421.yf76n7jui3z5bbn4@dhcp22.suse.cz>
 <20171024121859.4zd3zaafnjnlem4i@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024121859.4zd3zaafnjnlem4i@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 24, 2017 at 02:18:59PM +0200, Michal Hocko wrote:
> Does this sound something that you would be interested in? I can spend
> som more time on it if it is worthwhile.

Before you invest too much time in this, I think the rationale for
changing the current behavior so far is very weak. The ideas that have
been floated around in this thread barely cross into nice-to-have
territory, and as a result the acceptable additional complexity to
implement them is very low as well.

Making the OOM behavior less consistent, or introducing very rare
problem behavior (e.g. merely reducing the probability of syscalls
returning -ENOMEM instead of fully eliminating it, re-adding avenues
for deadlocks, no matter how rare, etc.) is a non-starter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
