Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00C156B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 04:09:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c6so97526469pfj.5
        for <linux-mm@kvack.org>; Mon, 15 May 2017 01:09:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33si9772014plk.81.2017.05.15.01.09.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 01:09:50 -0700 (PDT)
Date: Mon, 15 May 2017 10:09:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 8 Gigabytes and constantly swapping
Message-ID: <20170515080945.GA6062@dhcp22.suse.cz>
References: <171e8fa1-3f14-dc18-09b5-48399b250a30@internode.on.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <171e8fa1-3f14-dc18-09b5-48399b250a30@internode.on.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arthur Marsh <arthur.marsh@internode.on.net>
Cc: linux-mm@kvack.org

On Fri 12-05-17 18:21:27, Arthur Marsh wrote:
> I've been building the Linus git head kernels as the source gets updated and
> the one built about 3 hours ago managed to get stuck with kswapd0 as the
> highest consumer of CPU cycles (but still under 1 percent) of processes
> listed by top for over 15 minutes, after which I hit the power switch and
> rebooted with a Debian 4.11.0 kernel.
> 
> The previous kernel built less than 24 hours earlier did not have this
> problem.
> 
> CPU is an Athlon64 (Athlon II X4, 4 cores), RAM is 8GiB, swap is 4GiB, load
> was mainly firefox and chromium. Opening a new window in chromium seemed to
> help trigger the problem.
> 
> It's not much information to go on, just wondered if anyone else had
> experienced similar issues?
> 
> I'm happy to supply more configuration information and run tests including
> with kernels built with test patches applied.

Is this 32b or 64b kernel? Could you take /proc/vmstat snapshots ever
second while the kswapd is active?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
