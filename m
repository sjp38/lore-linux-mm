Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 127676B0253
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 09:26:19 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id p202so4007544iod.18
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 06:26:19 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w132si910985iow.9.2018.01.15.06.26.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 06:26:17 -0800 (PST)
Subject: Re: INFO: task hung in filemap_fault
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CACT4Y+bkuk3dkwdn7QCbWWWJ=R_nW8Qi6+y35VofLEHYu+6m7w@mail.gmail.com>
	<201801151944.FII09821.FMVQFJtHOOOSLF@I-love.SAKURA.ne.jp>
	<CACT4Y+ZE_7wuJV1V8J+zO2E+CKp8wpCsVfUMqCLXazmjrCRrUQ@mail.gmail.com>
	<201801152256.HDH17623.tSJHFLFOFMVOQO@I-love.SAKURA.ne.jp>
	<CACT4Y+Z2d6aV86rj5OYiv5Xw=D9xi=vW7RpdzP2X+vTnUjFqfQ@mail.gmail.com>
In-Reply-To: <CACT4Y+Z2d6aV86rj5OYiv5Xw=D9xi=vW7RpdzP2X+vTnUjFqfQ@mail.gmail.com>
Message-Id: <201801152325.FGE87548.tSLMFOVHFJOFQO@I-love.SAKURA.ne.jp>
Date: Mon, 15 Jan 2018 23:25:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com
Cc: bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com, ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, axboe@kernel.dk, tom.leiming@gmail.com, hare@suse.de, osandov@fb.com, shli@fb.com

Dmitry Vyukov wrote:
> >> I am not completely following. You previously mentioned raw.log, which
> >> is a collection of multiple programs, but now you seem to be talking
> >> about a single reproducer. When syzbot manages to reproduce the bug
> >> only with syzkaller program but not with a corresponding C program, it
> >> provides only syzkaller program. It such case it can sense to convert.
> >> But the case you pointed to actually contains C program. So there is
> >> no need to do the conversion at all... What am I missing?
> >>
> >
> > raw.log is not readable for me.
> > I want to see C program even if syzbot did not manage to reproduce the bug.
> > If C program is available, everyone can try reproducing the bug with manually
> > trimmed C program.
> 
> If it did not manage to reproduce the bug, there is no C program.
> There is no program at all.
> 

What!? Then, what does raw.log contain? I want to read raw.log as C program.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
