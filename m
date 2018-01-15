Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 751266B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 09:38:45 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id d28so7180720oic.15
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 06:38:45 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d4si3382098oib.523.2018.01.15.06.38.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 06:38:44 -0800 (PST)
Subject: Re: INFO: task hung in filemap_fault
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CACT4Y+ZE_7wuJV1V8J+zO2E+CKp8wpCsVfUMqCLXazmjrCRrUQ@mail.gmail.com>
	<201801152256.HDH17623.tSJHFLFOFMVOQO@I-love.SAKURA.ne.jp>
	<CACT4Y+Z2d6aV86rj5OYiv5Xw=D9xi=vW7RpdzP2X+vTnUjFqfQ@mail.gmail.com>
	<201801152325.FGE87548.tSLMFOVHFJOFQO@I-love.SAKURA.ne.jp>
	<CACT4Y+abO438-ncA83M296BQUMi+Ya0ZZRzY35uMD9QfOobhAA@mail.gmail.com>
In-Reply-To: <CACT4Y+abO438-ncA83M296BQUMi+Ya0ZZRzY35uMD9QfOobhAA@mail.gmail.com>
Message-Id: <201801152338.EBJ73933.FLSJHFVtOFOOQM@I-love.SAKURA.ne.jp>
Date: Mon, 15 Jan 2018 23:38:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com
Cc: bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com, ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, axboe@kernel.dk, tom.leiming@gmail.com, hare@suse.de, osandov@fb.com, shli@fb.com

Dmitry Vyukov wrote:
> On Mon, Jan 15, 2018 at 3:25 PM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > Dmitry Vyukov wrote:
> >> >> I am not completely following. You previously mentioned raw.log, which
> >> >> is a collection of multiple programs, but now you seem to be talking
> >> >> about a single reproducer. When syzbot manages to reproduce the bug
> >> >> only with syzkaller program but not with a corresponding C program, it
> >> >> provides only syzkaller program. It such case it can sense to convert.
> >> >> But the case you pointed to actually contains C program. So there is
> >> >> no need to do the conversion at all... What am I missing?
> >> >>
> >> >
> >> > raw.log is not readable for me.
> >> > I want to see C program even if syzbot did not manage to reproduce the bug.
> >> > If C program is available, everyone can try reproducing the bug with manually
> >> > trimmed C program.
> >>
> >> If it did not manage to reproduce the bug, there is no C program.
> >> There is no program at all.
> >>
> >
> > What!? Then, what does raw.log contain? I want to read raw.log as C program.
> 
> 
> raw.log is not a _program_, it's hundreds of separate programs that
> were executed before the crash.

I want to know the hundreds of separate programs as C programs.
Even if there are hundreds, more recently ran programs tend to be
the culprit.

>                                 It's also very compressed
> representation as compared to equivalent C programs. For example for
> this program:
> 
> mmap(&(0x7f0000000000/0xfff000)=nil, 0xfff000, 0x3, 0x32,
> 0xffffffffffffffff, 0x0)
> r0 = socket$nl_generic(0x10, 0x3, 0x10)
> sendmsg$nl_generic(r0,
> &(0x7f0000b3e000-0x38)={&(0x7f0000d4a000-0xc)={0x10, 0x0, 0x0, 0x0},
> 0xc, &(0x7f0000007000)={&(0x7f0000f7c000-0x15c)={0x24, 0x1c, 0x109,
> 0xffffffffffffffff, 0xffffffffffffffff, {0x4, 0x0, 0x0},
> [@nested={0x10, 0x9, [@typed={0xc, 0x0, @u32=0x0}]}]}, 0x24}, 0x1,
> 0x0, 0x0, 0x0}, 0x0)
> 
> you can get up to this amount of C code:
> https://gist.githubusercontent.com/dvyukov/eeaeb4e4ac45c3a251f72098c9295bf9/raw/700cd583507eca90711ba11b42e406f317553371/gistfile1.txt
> 
> that is, 700 lines of C source for 3 line program. So instead of a 1MB
> file that will be 100MB, and then it probably should be a gzip archive
> with hundreds of separate C files. There are people on this list
> complaining even about 200K of attachments. I don't see that this will
> be better and well accepted.
> 

I don't think attaching to mails is acceptable. Thus, I suggest e.g. CGI
service so that only those who want to try can obtain the C programs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
