Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79E326B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 09:39:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e64so43158263pfd.3
        for <linux-mm@kvack.org>; Fri, 12 May 2017 06:39:29 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id h15si3433097plk.259.2017.05.12.06.39.27
        for <linux-mm@kvack.org>;
        Fri, 12 May 2017 06:39:28 -0700 (PDT)
Subject: Re: 8 Gigabytes and constantly swapping
References: <171e8fa1-3f14-dc18-09b5-48399b250a30@internode.on.net>
 <64c96dd6-651c-eee8-2a30-65e60988d7d8@I-love.SAKURA.ne.jp>
From: Arthur Marsh <arthur.marsh@internode.on.net>
Message-ID: <b64f3ec1-0839-3051-d030-164625620712@internode.on.net>
Date: Fri, 12 May 2017 23:09:24 +0930
MIME-Version: 1.0
In-Reply-To: <64c96dd6-651c-eee8-2a30-65e60988d7d8@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org



Tetsuo Handa wrote on 12/05/17 20:26:
> On 2017/05/12 17:51, Arthur Marsh wrote:
>> I've been building the Linus git head kernels as the source gets updated and
>> the one built about 3 hours ago managed to get stuck with kswapd0 as the highest
>> consumer of CPU cycles (but still under 1 percent) of processes listed by top for
>> over 15 minutes, after which I hit the power switch and rebooted with a Debian
>> 4.11.0 kernel.
>
> Did the /bin/top process continue showing up-to-dated statistics rather than
> refrain from showing up-to-dated statistics? (I wonder why you had to hit
> the power switch before trying SysRq-m/SysRq-f etc.)

Yes, the /bin/top process continued updating.

The load average reached a high figure (over 14).

kswapd0 was using more CPU cycles than anything else but was still under 
1 percent.

There was still a lot of swap space free (about 3 GiB).

buffer/cache dropped below 1 GiB out of 8 GiB RAM.

I would have used alt-sysrq-f but had only recently enabled it in my 
kernel builds and didn't think to look it up on my other pc.

>
> If yes, assuming that reading statistics involves memory allocation requests,
> there was no load at at all despite firefox and chromium were running?

Wait time was over 98 percent, load average over 14.

>
> If no, all allocation requests got stuck waiting for memory reclaim?
...
> More description of what happened and how you confirmed that
> the /bin/top process continued working would be helpful.
>
>

It was as if kswapd0 was just left waiting to swap pages in and out 
without any other processes getting to complete what they were trying to do.

It does seem to be related to chromium starting up several processes 
when opening extra windows/tabs.

Thanks for your help!

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
