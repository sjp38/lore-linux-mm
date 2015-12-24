Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6E60282F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 01:27:06 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id p187so172514155wmp.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 22:27:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df7si69611772wjc.222.2015.12.23.22.27.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Dec 2015 22:27:04 -0800 (PST)
Subject: Re: OOM killer kicks in after minutes or never
References: <20151221123557.GE3060@orkisz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <567B9042.9010105@suse.cz>
Date: Thu, 24 Dec 2015 07:27:14 +0100
MIME-Version: 1.0
In-Reply-To: <20151221123557.GE3060@orkisz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Szewczyk <Marcin.Szewczyk@wodny.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>
Cc: Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>

+CC so this doesn't get lost

On 21.12.2015 13:35, Marcin Szewczyk wrote:
> Hi,
> 
> In 2010 I noticed that viewing many GIFs in a row using gpicview renders
> my Linux unresponsive. There is very little I can do in such a
> situation. Rarely after some minutes the OOM killer kicks in and saves
> the day. Nevertheless, usually I end up using Alt+SysRq+B.
> 
> This is the second computer I can observe this problem on. First was
> Asus EeePC 1000 with Atom N270 and now I have Lenovo S210 with Celeron
> 1037U.
> 
> What happens is gpicview exhausting whole available memory in such a
> pattern that userspace becomes unresponsive. I cannot switch to another
> terminal either. I have written a tool that allocates memory in a very
> similar way using GDK -- https://github.com/wodny/crasher.
> 
> I have also uploaded some logs to the repository -- top, iostat (showing
> a lot of reads during an episode), dmesg.
> 
> I suppose the OS starts to oscillate between freeing memory, cleaning
> caches and buffers, and loading some new data (see iostat logs).
> 
> Currently I am using Debian Jessie with the following kernel:
> 3.16.0-4-amd64 #1 SMP Debian 3.16.7-ckt11-1+deb8u6 (2015-11-09) x86_64 GNU/Linux
> 
> I can observe the most impressive effects on my physical machine
> (logs/ph-*). On a VM (logs/vm-*) usually the OOM killer kills the
> process after a short time (5-120 seconds).
> 
> Possible factors differentiating cases of recovering in seconds from
> recoveries after minutes (or never):
> - another memory-consuming process running (e.g. Firefox),
> - physical machine or a VM (see dmesg logs),
> - chipset and associated kernel functions (see dmesg logs).
> 
> Things that seem irrelevant (after testing):
> - running the application in Xorg or a TTY,
> - LUKS encryption of the root filesystem,
> - vm.oom_kill_allocating_task setting.
> 
> What can I do to diagnose the problem further?
> 
> 
> (Sorry if a duplicate appears)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
