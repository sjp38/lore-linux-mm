Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CBA536B0005
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 03:45:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d22-v6so2937085pfn.3
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 00:45:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 62-v6si7415675pfu.79.2018.08.09.00.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 00:45:27 -0700 (PDT)
Date: Thu, 9 Aug 2018 09:45:23 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
Message-ID: <20180809074523.GA16149@kroah.com>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
 <20180808072040.GC27972@dhcp22.suse.cz>
 <d17e65bb-c114-55de-fb4e-e2f538779b92@virtuozzo.com>
 <20180808102734.GH27972@dhcp22.suse.cz>
 <20180808213125.GM2234@dastard>
 <20180809000708.GA5566@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180809000708.GA5566@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, akpm@linux-foundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 08, 2018 at 05:07:08PM -0700, Matthew Wilcox wrote:
> On Thu, Aug 09, 2018 at 07:31:25AM +1000, Dave Chinner wrote:
> > IMO, we've had enough recent bugs to deal with from shrinkers being
> > called before the filesystem is set up and from trying to handle
> > allocation errors during setup. Do we really want to make shrinker
> > shutdown just as prone to mismanagement and subtle, hard to hit
> > bugs? I don't think we do - unmount is simply not a critical
> > performance path.
> 
> It's never been performance critical for me, but I'm not so sure that
> there aren't container workloads which unmount filesystems multiple
> times per second.

What?  Why would they do that?  Who cares about tear-down speeds?  Start
up speeds I can kind of understand...
