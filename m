Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC7306B000D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 03:20:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v26-v6so577192eds.9
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 00:20:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 25-v6si3847618edu.218.2018.08.08.00.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 00:20:44 -0700 (PDT)
Date: Wed, 8 Aug 2018 09:20:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
Message-ID: <20180808072040.GC27972@dhcp22.suse.cz>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue 07-08-18 18:37:36, Kirill Tkhai wrote:
> This patch kills all CONFIG_SRCU defines and
> the code under !CONFIG_SRCU.

The last time somebody tried to do this there was a pushback due to
kernel tinyfication. So this should really give some numbers about the
code size increase. Also why can't we make this depend on MMU. Is
anybody else than the reclaim asking for unconditional SRCU usage?

Btw. I totaly agree with Steven. This is a very poor changelog. It is
trivial to see what the patch does but it is far from clear why it is
doing that and why we cannot go other ways.
-- 
Michal Hocko
SUSE Labs
