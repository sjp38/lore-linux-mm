Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB4DD4403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 06:42:49 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 4so843330pge.8
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 03:42:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a23si3617003pgd.261.2017.11.08.03.42.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 03:42:48 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: add sysctl to control global OOM logging
 behaviour
References: <20171108091843.29349-1-dmonakhov@openvz.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <24fb6865-6cc5-2af0-3a99-ea9495791f66@I-love.SAKURA.ne.jp>
Date: Wed, 8 Nov 2017 20:42:37 +0900
MIME-Version: 1.0
In-Reply-To: <20171108091843.29349-1-dmonakhov@openvz.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Monakhov <dmonakhov@openvz.org>, linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, vdavydov.dev@gmail.com

On 2017/11/08 18:18, Dmitry Monakhov wrote:
> Our systems becomes bigger and bigger, but OOM still happens.
> This becomes serious problem for systems where OOM happens
> frequently(containers, VM) because each OOM generate pressure
> on dmesg log infrastructure. Let's allow system administrator
> ability to tune OOM dump behaviour

Majority of OOM killer related messages are from dump_header().
Thus, allow tuning __ratelimit(&oom_rs) might make sense.

But other lines

  "%s: Kill process %d (%s) score %u or sacrifice child\n"
  "Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"
  "oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"

should not cause problems, for it is easy to exclude such lines from
your dmesg log infrastructure using fgrep match.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
