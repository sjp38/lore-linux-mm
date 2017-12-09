Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF9F6B0033
	for <linux-mm@kvack.org>; Sat,  9 Dec 2017 09:15:04 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id q12so2053138pli.12
        for <linux-mm@kvack.org>; Sat, 09 Dec 2017 06:15:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y3si8056483pfj.120.2017.12.09.06.14.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 09 Dec 2017 06:14:58 -0800 (PST)
Subject: Re: Google Chrome cause locks held in system (kernel 4.15 rc2)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1512705038.7843.6.camel@gmail.com>
	<20171208040556.GG19219@magnolia>
	<b60ae517-b9ca-a07f-36cf-ed11eb3c9180@I-love.SAKURA.ne.jp>
	<1512825438.4168.14.camel@gmail.com>
In-Reply-To: <1512825438.4168.14.camel@gmail.com>
Message-Id: <201712092314.IGI39555.MtFFVLJFOQOSOH@I-love.SAKURA.ne.jp>
Date: Sat, 9 Dec 2017 23:14:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikhail.v.gavrilov@gmail.com, mhocko@kernel.org
Cc: darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

mikhail wrote:
> On Fri, 2017-12-08 at 19:18 +0900, Tetsuo Handa wrote:
> > Most likely cause is that I/O was getting very slow due to memory
> > pressure.
> > Running memory consuming processes (e.g. web browsers) and file
> > writing
> > processes might generate stresses like this report.
> > 
> > I can't tell whether this report is a real deadlock/lockup or just a
> > slowdown,
> > for currently we don't have means for checking whether memory
> > allocation was
> > making progress or not.
> 
> It not just slowdown because after 5 hours I was still unable launch
> even htop. After executing command was nothing happens. I was even
> surprised that dmesg could work.

Then, it seems that it was a real deadlock/lockup.

> 
> Thanks for the advice.
> Decided to check what happens when I do SysRq-t.
> SysRq-t produce a lot of the output even without running Google Chrome.
> Such amout of data does not fit in the kernel output buffer and it's
> impossible to read from the screen.
> 
> Demonstration: https://youtu.be/DUWB1WGBog0

Under OOM lockup situation, kernel messages can unlikely be saved to syslog
files, for writing to files involves memory allocation. Can you set up
netconsole or serial console explained at
http://events.linuxfoundation.org/sites/events/files/slides/LCJ2014-en_0.pdf ?
If neither console is possible, it would become difficult to debug.

Michal, any idea?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
