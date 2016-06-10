Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6606B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 09:06:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u74so30614247lff.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 06:06:30 -0700 (PDT)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id 78si6836485ljf.85.2016.06.10.06.06.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 06:06:29 -0700 (PDT)
Received: by mail-lf0-x229.google.com with SMTP id j7so21975482lfg.1
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 06:06:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1606101253090.28031@nanos>
References: <CACT4Y+YwV++Eb8n-1q94zW7_rOOX=p8_+8ERD9L07cjrBf7ysw@mail.gmail.com>
 <CACT4Y+ZTFGqVjokXUefFMJOrhAn+go3hPKvQRdAhgRRhab5GrQ@mail.gmail.com>
 <CACT4Y+b8f7=ZnvXnzP17nDwa_jvDeTTQY_Wy7wsiohRssDULhQ@mail.gmail.com>
 <alpine.DEB.2.11.1606092240030.28031@nanos> <CACT4Y+YWqcCU0z+LS5BboJOxMRYys_sbUPQTA5to5GcUUQK4LQ@mail.gmail.com>
 <alpine.DEB.2.11.1606101253090.28031@nanos>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 10 Jun 2016 15:06:08 +0200
Message-ID: <CACT4Y+ZQZKd=a=F2CF4seh-DpCRTT8aHjA21Xq3dSgg8g3U0kg@mail.gmail.com>
Subject: Re: x86: bad pte in pageattr_test
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>

On Fri, Jun 10, 2016 at 2:54 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Fri, 10 Jun 2016, Dmitry Vyukov wrote:
>> Here is the second log:
>> https://gist.githubusercontent.com/dvyukov/dd7970a5daaa7a30f6d37fa5592b56de/raw/f29182024538e604c95d989f7b398816c3c595dc/gistfile1.txt
>>
>> I've hit only twice. The first time I tried hard to reproduce it, with
>> no success. So unfortunately that's all we have.
>>
>> Re logs: my setup executes up to 16 programs in parallel. So for
>> normal BUGs any of the preceding 16 programs can be guilty. But since
>> this check is asynchronous, it can be just any preceding program in
>> the log.
>
> Ok.
>
>> I would expect that it is triggered by some rarely-executing poorly
>> tested code. Maybe mmap of some device?
>
> That's the mmap(dev) list which is common between the two log files:
>
> vcsn
> ircomm
> rfkill
> userio
> dspn
> mice
> midi
> sndpcmc
> hidraw0
> vga_arbiter
> lightnvm
> sr
>
> Dunno, if that's the right direction, but exposing these a bit more might be
> worth to try.


I am now running both of these logs for several hours (2.5M
executions). No failures so far...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
