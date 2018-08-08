Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 28DA96B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 20:55:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f13-v6so228194pgs.15
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 17:55:29 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q35-v6si2824096pgb.219.2018.08.07.17.55.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 17:55:27 -0700 (PDT)
Date: Tue, 7 Aug 2018 20:55:22 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
Message-ID: <20180807205522.13771e51@vmware.local.home>
In-Reply-To: <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
	<153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, mhocko@suse.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, 07 Aug 2018 18:37:36 +0300
Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> This patch kills all CONFIG_SRCU defines and
> the code under !CONFIG_SRCU.

Can you add the rationale for removing the SRCU config in the change log
please.

Thanks!

-- Steve

> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  drivers/base/core.c                                |   42 --------------------
>  include/linux/device.h                             |    2 -
>  include/linux/rcutiny.h                            |    4 --
>  include/linux/srcu.h                               |    5 --
>  kernel/notifier.c                                  |    3 -
>  kernel/rcu/Kconfig                                 |   12 +-----
>  kernel/rcu/tree.h                                  |    5 --
>  kernel/rcu/update.c                                |    4 --
>  .../selftests/rcutorture/doc/TREE_RCU-kconfig.txt  |    5 --
>  9 files changed, 3 insertions(+), 79 deletions(-)
> 
>
