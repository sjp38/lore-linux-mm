Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D00E6B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 06:56:44 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i63so44473612pgd.15
        for <linux-mm@kvack.org>; Fri, 12 May 2017 03:56:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p13si3143277pgd.368.2017.05.12.03.56.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 12 May 2017 03:56:43 -0700 (PDT)
Subject: Re: 8 Gigabytes and constantly swapping
References: <171e8fa1-3f14-dc18-09b5-48399b250a30@internode.on.net>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <64c96dd6-651c-eee8-2a30-65e60988d7d8@I-love.SAKURA.ne.jp>
Date: Fri, 12 May 2017 19:56:31 +0900
MIME-Version: 1.0
In-Reply-To: <171e8fa1-3f14-dc18-09b5-48399b250a30@internode.on.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arthur Marsh <arthur.marsh@internode.on.net>
Cc: linux-mm@kvack.org

On 2017/05/12 17:51, Arthur Marsh wrote:
> I've been building the Linus git head kernels as the source gets updated and
> the one built about 3 hours ago managed to get stuck with kswapd0 as the highest
> consumer of CPU cycles (but still under 1 percent) of processes listed by top for
> over 15 minutes, after which I hit the power switch and rebooted with a Debian
> 4.11.0 kernel.

Did the /bin/top process continue showing up-to-dated statistics rather than
refrain from showing up-to-dated statistics? (I wonder why you had to hit
the power switch before trying SysRq-m/SysRq-f etc.)

If yes, assuming that reading statistics involves memory allocation requests,
there was no load at at all despite firefox and chromium were running?

If no, all allocation requests got stuck waiting for memory reclaim?

> 
> The previous kernel built less than 24 hours earlier did not have this problem.
> 
> CPU is an Athlon64 (Athlon II X4, 4 cores), RAM is 8GiB, swap is 4GiB, load was
> mainly firefox and chromium. Opening a new window in chromium seemed to help
> trigger the problem.
> 
> It's not much information to go on, just wondered if anyone else had experienced
> similar issues?
> 
> I'm happy to supply more configuration information and run tests including with
> kernels built with test patches applied.

I don't know but http://lkml.kernel.org/r/20170316100409.GR802@shells.gnugeneration.com
or http://lkml.kernel.org/r/20170502041235.zqmywvj5tiiom3jk@merlins.org ?
More description of what happened and how you confirmed that
the /bin/top process continued working would be helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
