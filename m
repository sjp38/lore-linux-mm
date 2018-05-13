Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E48BE6B06F7
	for <linux-mm@kvack.org>; Sat, 12 May 2018 22:06:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c4-v6so7244531pfg.22
        for <linux-mm@kvack.org>; Sat, 12 May 2018 19:06:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c22-v6si5400234pgn.169.2018.05.12.19.06.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 May 2018 19:06:25 -0700 (PDT)
Subject: Re: BUG: workqueue lockup (2)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <94eb2c03c9bc75aff2055f70734c@google.com>
	<001a113f711a528a3f0560b08e76@google.com>
	<20180512215222.GC817@sol.localdomain>
In-Reply-To: <20180512215222.GC817@sol.localdomain>
Message-Id: <201805131106.GFF73973.OOtMVQFSFOJFHL@I-love.SAKURA.ne.jp>
Date: Sun, 13 May 2018 11:06:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ebiggers3@gmail.com, bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com, peter@hurleysoftware.com
Cc: dvyukov@google.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pombredanne@nexb.com, syzkaller-bugs@googlegroups.com, tglx@linutronix.de

Eric Biggers wrote:
> The bug that this reproducer reproduces was fixed a while ago by commit
> 966031f340185e, so I'm marking this bug report fixed by it:
> 
> #syz fix: n_tty: fix EXTPROC vs ICANON interaction with TIOCINQ (aka FIONREAD)

Nope. Commit 966031f340185edd ("n_tty: fix EXTPROC vs ICANON interaction with
TIOCINQ (aka FIONREAD)") is "Wed Dec 20 17:57:06 2017 -0800" but the last
occurrence on linux.git (commit 008464a9360e31b1 ("Merge branch 'for-linus' of
git://git.kernel.org/pub/scm/linux/kernel/git/jikos/hid")) is only a few days ago
("Wed May 9 10:49:52 2018 -1000").

> 
> Note that the error message was not always "BUG: workqueue lockup"; it was also
> sometimes like "watchdog: BUG: soft lockup - CPU#5 stuck for 22s!".
> 
> syzbot still is hitting the "BUG: workqueue lockup" error sometimes, but it must
> be for other reasons.  None has a reproducer currently.

The last occurrence on linux.git is considered as a duplicate of

  [upstream] INFO: rcu detected stall in n_tty_receive_char_special
  https://syzkaller.appspot.com/bug?id=3d7481a346958d9469bebbeb0537d5f056bdd6e8

which we already have a reproducer at
https://groups.google.com/d/msg/syzkaller-bugs/O4DbPiJZFBY/YCVPocx3AgAJ
and debug output is available at
https://groups.google.com/d/msg/syzkaller-bugs/O4DbPiJZFBY/TxQ7WS5ZAwAJ .

We are currently waiting for comments from Peter Hurley who added that code.
