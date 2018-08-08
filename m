Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B609F6B0006
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 12:13:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y13-v6so1959575wma.1
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 09:13:55 -0700 (PDT)
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id p129-v6si4130903wme.120.2018.08.08.09.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 08 Aug 2018 09:13:51 -0700 (PDT)
Date: Wed, 8 Aug 2018 09:13:30 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
Message-ID: <20180808161330.GA22863@localhost>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
 <20180808072040.GC27972@dhcp22.suse.cz>
 <d17e65bb-c114-55de-fb4e-e2f538779b92@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d17e65bb-c114-55de-fb4e-e2f538779b92@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 08, 2018 at 01:17:44PM +0300, Kirill Tkhai wrote:
> On 08.08.2018 10:20, Michal Hocko wrote:
> > On Tue 07-08-18 18:37:36, Kirill Tkhai wrote:
> >> This patch kills all CONFIG_SRCU defines and
> >> the code under !CONFIG_SRCU.
> > 
> > The last time somebody tried to do this there was a pushback due to
> > kernel tinyfication. So this should really give some numbers about the
> > code size increase. Also why can't we make this depend on MMU. Is
> > anybody else than the reclaim asking for unconditional SRCU usage?
> 
> I don't know one. The size numbers (sparc64) are:
> 
> $ size image.srcu.disabled 
>    text	   data	    bss	    dec	    hex	filename
> 5117546	8030506	1968104	15116156	 e6a77c	image.srcu.disabled
> $ size image.srcu.enabled
>    text	   data	    bss	    dec	    hex	filename
> 5126175	8064346	1968104	15158625	 e74d61	image.srcu.enabled
> The difference is: 15158625-15116156 = 42469 ~41Kb

41k is a *substantial* size increase. However, can you compare
tinyconfig with and without this patch? That may have a smaller change.
