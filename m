Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0866B02A4
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 08:45:08 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v78so2581608pgb.18
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 05:45:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t128si3892477pgc.68.2017.11.08.05.45.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 05:45:07 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: add sysctl to control global OOM logging behaviour
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171108091843.29349-1-dmonakhov@openvz.org>
	<24fb6865-6cc5-2af0-3a99-ea9495791f66@I-love.SAKURA.ne.jp>
	<87inelklnd.fsf@openvz.org>
In-Reply-To: <87inelklnd.fsf@openvz.org>
Message-Id: <201711082245.BGF12900.VFFOLJHOOMtSFQ@I-love.SAKURA.ne.jp>
Date: Wed, 8 Nov 2017 22:45:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dmonakhov@openvz.org, linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, vdavydov.dev@gmail.com

Dmitry Monakhov wrote:
> Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:
> 
> > On 2017/11/08 18:18, Dmitry Monakhov wrote:
> >> Our systems becomes bigger and bigger, but OOM still happens.
> >> This becomes serious problem for systems where OOM happens
> >> frequently(containers, VM) because each OOM generate pressure
> >> on dmesg log infrastructure. Let's allow system administrator
> >> ability to tune OOM dump behaviour
> >
> > Majority of OOM killer related messages are from dump_header().
> > Thus, allow tuning __ratelimit(&oom_rs) might make sense.
> >
> > But other lines
> >
> >   "%s: Kill process %d (%s) score %u or sacrifice child\n"
> >   "Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"
> >   "oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"
> This still may result in hundreds of messages per second.

Then, it means that your system is invoking the OOM killer one hundred times
per second (every 10 milliseconds). I think that such system is far from properly
configured.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
