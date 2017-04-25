Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9836F6B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 02:33:08 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id p187so19323810qkd.11
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 23:33:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m8si20982494qtf.56.2017.04.24.23.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 23:33:07 -0700 (PDT)
Date: Tue, 25 Apr 2017 08:33:03 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170425063245.GA8208@redhat.com>
References: <20170309180540.GA8678@cmpxchg.org>
 <20170310102010.GD3753@dhcp22.suse.cz>
 <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
 <201704231924.GDF05718.LQSMtJOOFOFHFV@I-love.SAKURA.ne.jp>
 <20170424123936.GA6152@redhat.com>
 <201704242206.IEF52621.HFJLFFtOSVOQMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704242206.IEF52621.HFJLFFtOSVOQMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com

On Mon, Apr 24, 2017 at 10:06:32PM +0900, Tetsuo Handa wrote:
> Stanislaw Gruszka wrote:
> > On Sun, Apr 23, 2017 at 07:24:21PM +0900, Tetsuo Handa wrote:
> > > On 2017/03/10 20:44, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > >> I am definitely not against. There is no reason to rush the patch in.
> > > > 
> > > > I don't hurry if we can check using watchdog whether this problem is occurring
> > > > in the real world. I have to test corner cases because watchdog is missing.
> > > > 
> > > Ping?
> > > 
> > > This problem can occur even immediately after the first invocation of
> > > the OOM killer. I believe this problem can occur in the real world.
> > > When are we going to apply this patch or watchdog patch?
> > > 
> > > ----------------------------------------
> > > [    0.000000] Linux version 4.11.0-rc7-next-20170421+ (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #588 SMP Sun Apr 23 17:38:02 JST 2017
> > > [    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc7-next-20170421+ root=UUID=17c3c28f-a70a-4666-95fa-ecf6acd901e4 ro vconsole.keymap=jp106 crashkernel=256M vconsole.font=latarcyrheb-sun16 security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8 debug_guardpage_minorder=1
> > 
> > Are you debugging memory corruption problem?
> 
> No. Just a random testing trying to find how we can avoid flooding of
> warn_alloc_stall() warning messages while also avoiding ratelimiting.

This is not right way to stress mm subsystem, debug_guardpage_minorder= 
option is for _debug_ purpose. Use mem= instead if you want to limit
available memory.

> > FWIW, if you use debug_guardpage_minorder= you can expect any
> > allocation memory problems. This option is intended to debug
> > memory corruption bugs and it shrinks available memory in 
> > artificial way. Taking that, I don't think justifying any
> > patch, by problem happened when debug_guardpage_minorder= is 
> > used, is reasonable.
> >  
> > Stanislaw
> 
> This problem occurs without debug_guardpage_minorder= parameter and

So please justify your patches by that.

Thanks
Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
