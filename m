Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5299F6B0007
	for <linux-mm@kvack.org>; Tue,  1 May 2018 12:12:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p189so10733969pfp.1
        for <linux-mm@kvack.org>; Tue, 01 May 2018 09:12:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l11-v6sor1124644pgs.224.2018.05.01.09.12.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 May 2018 09:12:38 -0700 (PDT)
Subject: Re: INFO: task hung in wb_shutdown (2)
References: <94eb2c05b2d83650030568cc8bd9@google.com>
 <e56c1600-8923-dd6b-d065-c2fd2a720404@I-love.SAKURA.ne.jp>
 <43302799-1c50-4cab-b974-9fe1ca584813@I-love.SAKURA.ne.jp>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <16c2860a-05db-9534-5960-e26c9ba9214c@kernel.dk>
Date: Tue, 1 May 2018 10:12:34 -0600
MIME-Version: 1.0
In-Reply-To: <43302799-1c50-4cab-b974-9fe1ca584813@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>
Cc: syzbot <syzbot+c0cf869505e03bdf1a24@syzkaller.appspotmail.com>, christophe.jaillet@wanadoo.fr, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com, weiping zhang <zhangweiping@didichuxing.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-block@vger.kernel.org

On 5/1/18 4:27 AM, Tetsuo Handa wrote:
> Tejun, Jan, Jens,
> 
> Can you review this patch? syzbot has hit this bug for nearly 4000 times but
> is still unable to find a reproducer. Therefore, the only way to test would be
> to apply this patch upstream and test whether the problem is solved.

I'll review it today.

-- 
Jens Axboe
