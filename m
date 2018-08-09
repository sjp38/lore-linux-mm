Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1CAB56B0005
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 20:08:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w11-v6so1764272plq.8
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 17:08:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i6-v6si4984419pgt.352.2018.08.08.17.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 08 Aug 2018 17:08:10 -0700 (PDT)
Date: Wed, 8 Aug 2018 17:07:08 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
Message-ID: <20180809000708.GA5566@bombadil.infradead.org>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
 <20180808072040.GC27972@dhcp22.suse.cz>
 <d17e65bb-c114-55de-fb4e-e2f538779b92@virtuozzo.com>
 <20180808102734.GH27972@dhcp22.suse.cz>
 <20180808213125.GM2234@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180808213125.GM2234@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 09, 2018 at 07:31:25AM +1000, Dave Chinner wrote:
> IMO, we've had enough recent bugs to deal with from shrinkers being
> called before the filesystem is set up and from trying to handle
> allocation errors during setup. Do we really want to make shrinker
> shutdown just as prone to mismanagement and subtle, hard to hit
> bugs? I don't think we do - unmount is simply not a critical
> performance path.

It's never been performance critical for me, but I'm not so sure that
there aren't container workloads which unmount filesystems multiple
times per second.
