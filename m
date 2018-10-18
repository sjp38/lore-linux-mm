Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id B61996B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 01:27:23 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id w137-v6so4904274itc.8
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 22:27:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o187-v6si3155964itb.30.2018.10.17.22.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 22:27:22 -0700 (PDT)
Message-Id: <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no eligible
 task.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 18 Oct 2018 14:26:57 +0900
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp> <20181018042739.GA650@jagdpanzerIV>
In-Reply-To: <20181018042739.GA650@jagdpanzerIV>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

Sergey Senozhatsky wrote:
> To my personal taste, "baud rate of registered and enabled consoles"
> approach is drastically more relevant than hard coded 10 * HZ or
> 60 * HZ magic numbers... But not in the form of that "min baud rate"
> brain fart, which I have posted.

I'm saying that my 60 * HZ is "duration which the OOM killer keeps refraining
 from calling printk()". Such period is required for allowing console users
to do their operations without being disturbed by the OOM killer.

Even if you succeeded to calculate average speed of the OOM killer messages
being flushed to consoles, printing the OOM killer messages with that speed
will keep the console users unable to do their operations.

Please do not print the OOM killer messages when the OOM killer cannot make
progress... It just disturbs console users.
