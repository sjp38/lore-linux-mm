Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0E106B0038
	for <linux-mm@kvack.org>; Sat, 13 May 2017 00:15:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u21so63803661pgn.5
        for <linux-mm@kvack.org>; Fri, 12 May 2017 21:15:27 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id e7si4872877pgc.297.2017.05.12.21.15.25
        for <linux-mm@kvack.org>;
        Fri, 12 May 2017 21:15:26 -0700 (PDT)
Subject: Re: 8 Gigabytes and constantly swapping
References: <171e8fa1-3f14-dc18-09b5-48399b250a30@internode.on.net>
 <64c96dd6-651c-eee8-2a30-65e60988d7d8@I-love.SAKURA.ne.jp>
 <b64f3ec1-0839-3051-d030-164625620712@internode.on.net>
From: Arthur Marsh <arthur.marsh@internode.on.net>
Message-ID: <521c29b0-809d-a0fd-50ca-d3d0df325dd4@internode.on.net>
Date: Sat, 13 May 2017 13:45:23 +0930
MIME-Version: 1.0
In-Reply-To: <b64f3ec1-0839-3051-d030-164625620712@internode.on.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org



Arthur Marsh wrote on 12/05/17 23:09:

> It does seem to be related to chromium starting up several processes
> when opening extra windows/tabs.

I tried using ionice -c3 on chromium, which meant that disk I/O by 
chromium should only occur when disk I/O was otherwise idle, and this 
made a major difference.

It appears that chromium's use of multiple processes and threads means 
that it effectively hogs all the disk I/O but ends up not being able to 
do much as different processes/threads are making different demands on 
disk I/O, leading to kswapd0 having the greatest CPU usage of any 
process but still under 1 percent of available CPU time and the system 
spending over 99 percent of the time in wait. All while about 1 GiB of 4 
GiB available swap is being used.

Is there any existing way to limit the chromium process tree to have the 
same amount of access to disk I/O as say firefox running as a single 
process?

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
