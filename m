Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6746B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 08:57:06 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id v15so11875601iob.22
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 05:57:06 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d3si38838itg.163.2018.01.15.05.57.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 05:57:05 -0800 (PST)
Subject: Re: INFO: task hung in filemap_fault
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CACT4Y+ZPHerom6rNYj8HL8vSySi7n4ArySnpFbxQX31n-QumNg@mail.gmail.com>
	<201801081948.HAE82801.FQOSHtMOFVLFOJ@I-love.SAKURA.ne.jp>
	<CACT4Y+bkuk3dkwdn7QCbWWWJ=R_nW8Qi6+y35VofLEHYu+6m7w@mail.gmail.com>
	<201801151944.FII09821.FMVQFJtHOOOSLF@I-love.SAKURA.ne.jp>
	<CACT4Y+ZE_7wuJV1V8J+zO2E+CKp8wpCsVfUMqCLXazmjrCRrUQ@mail.gmail.com>
In-Reply-To: <CACT4Y+ZE_7wuJV1V8J+zO2E+CKp8wpCsVfUMqCLXazmjrCRrUQ@mail.gmail.com>
Message-Id: <201801152256.HDH17623.tSJHFLFOFMVOQO@I-love.SAKURA.ne.jp>
Date: Mon, 15 Jan 2018 22:56:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com
Cc: bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com, ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, axboe@kernel.dk, tom.leiming@gmail.com, hare@suse.de, osandov@fb.com, shli@fb.com

Dmitry Vyukov wrote:
> > No problem. In the "tty: User triggerable soft lockup." case, I manually
> > trimmed the reproducer at https://marc.info/?l=linux-mm&m=151368630414963 .
> > That is,
> >
> >  (1) Can the problem be reproduced even if setup_tun(0, true); is commented out?
> >
> >  (2) Can the problem be reproduced even if NONFAILING(A = B); is replaced with
> >      plain A = B; assignment?
> >
> >  (3) Can the problem be reproduced even if install_segv_handler(); is commented
> >      out?
> >
> >  (4) Can the problem be reproduced even if some syscalls (e.g. __NR_memfd_create,
> >      __NR_getsockopt, __NR_perf_event_open) are replaced with no-op?
> >
> > and so on. Then, I finally reached a reproducer which I sent, and the bug was fixed.
> >
> > What is important is that everyone can try simplifying the reproducer written
> > in plain C in order to narrow down the culprit. Providing a (e.g.) CGI service
> > which generates plain C reproducer like gistfile1.txt will be helpful to me.
> 
> I am not completely following. You previously mentioned raw.log, which
> is a collection of multiple programs, but now you seem to be talking
> about a single reproducer. When syzbot manages to reproduce the bug
> only with syzkaller program but not with a corresponding C program, it
> provides only syzkaller program. It such case it can sense to convert.
> But the case you pointed to actually contains C program. So there is
> no need to do the conversion at all... What am I missing?
> 

raw.log is not readable for me.
I want to see C program even if syzbot did not manage to reproduce the bug.
If C program is available, everyone can try reproducing the bug with manually
trimmed C program.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
