Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 927056B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:20:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z20so13033987pfn.11
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:20:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id a9si994123pgq.655.2018.04.24.05.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 05:20:28 -0700 (PDT)
Subject: Re: INFO: task hung in wb_shutdown (2)
References: <94eb2c05b2d83650030568cc8bd9@google.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <e56c1600-8923-dd6b-d065-c2fd2a720404@I-love.SAKURA.ne.jp>
Date: Tue, 24 Apr 2018 21:19:54 +0900
MIME-Version: 1.0
In-Reply-To: <94eb2c05b2d83650030568cc8bd9@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>
Cc: syzbot <syzbot+c0cf869505e03bdf1a24@syzkaller.appspotmail.com>, christophe.jaillet@wanadoo.fr, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com, weiping zhang <zhangweiping@didichuxing.com>

