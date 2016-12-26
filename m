Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 03F076B0038
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 07:51:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k184so12266773wme.4
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 04:50:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s7si41375399wjz.203.2016.12.26.04.50.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Dec 2016 04:50:58 -0800 (PST)
Date: Mon, 26 Dec 2016 13:50:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [lkp-developer] [mm, memcg]  d18e2b2aca:
 WARNING:at_mm/memcontrol.c:#mem_cgroup_update_lru_size
Message-ID: <20161226125055.GC20715@dhcp22.suse.cz>
References: <20161223144738.GB23117@dhcp22.suse.cz>
 <20161225222556.GH19366@yexl-desktop>
 <20161226122651.GA20715@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161226122651.GA20715@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <xiaolong.ye@intel.com>
Cc: Nils Holland <nholland@tisys.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org, lkp@01.org

On Mon 26-12-16 13:26:51, Michal Hocko wrote:
> On Mon 26-12-16 06:25:56, kernel test robot wrote:
[...]
> > [   95.226364] init: tty6 main process (990) killed by TERM signal
> > [   95.314020] init: plymouth-upstart-bridge main process (1039) terminated with status 1
> > [   97.588568] ------------[ cut here ]------------
> > [   97.594364] WARNING: CPU: 0 PID: 1055 at mm/memcontrol.c:1032 mem_cgroup_update_lru_size+0xdd/0x12b
> > [   97.606654] mem_cgroup_update_lru_size(40297f00, 0, -1): lru_size 1 but empty
> > [   97.615140] Modules linked in:
> > [   97.618834] CPU: 0 PID: 1055 Comm: killall5 Not tainted 4.9.0-mm1-00095-gd18e2b2 #82
> > [   97.628008] Call Trace:
> > [   97.631025]  dump_stack+0x16/0x18
> > [   97.635107]  __warn+0xaf/0xc6
> > [   97.638729]  ? mem_cgroup_update_lru_size+0xdd/0x12b
> 
> Do you have the full backtrace?

It's not needed. I found the bug in my patch and it should be fixed by
the updated patch http://lkml.kernel.org/r/20161226124839.GB20715@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
