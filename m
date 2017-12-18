Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A28A6B0038
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 17:20:05 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id u126so7664788oif.23
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:20:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 48si495724otg.337.2017.12.18.14.20.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 14:20:04 -0800 (PST)
Subject: Re: INFO: task hung in filemap_fault
References: <001a11444d0e7bfd7f05609956c6@google.com>
 <82d89066-7dd2-12fe-3cc0-c8d624fe0d51@I-love.SAKURA.ne.jp>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <b434ed3e-c066-9618-96ca-fd66a362a4fe@I-love.SAKURA.ne.jp>
Date: Tue, 19 Dec 2017 07:19:45 +0900
MIME-Version: 1.0
In-Reply-To: <82d89066-7dd2-12fe-3cc0-c8d624fe0d51@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+980f5e5fc060c37505bd65abb49a963518b269d9@syzkaller.appspotmail.com>, ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jlayton@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com

On 2017/12/18 23:52, Tetsuo Handa wrote:
> On 2017/12/18 17:43, syzbot wrote:
>> Hello,
>>
>> syzkaller hit the following crash on 6084b576dca2e898f5c101baef151f7bfdbb606d
>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached
>> Raw console output is attached.
>>
>> Unfortunately, I don't have any reproducer for this bug yet.
>>
> 
> This log has a lot of mmap() but also has Android's binder messages.
> 
> r9 = syz_open_dev$binder(&(0x7f0000000000)='/dev/binder#\x00', 0x0, 0x800)
> 
> [   49.200735] binder: 9749:9755 IncRefs 0 refcount change on invalid ref 2 ret -22
> [   49.221514] binder: 9749:9755 Acquire 1 refcount change on invalid ref 4 ret -22
> [   49.233325] binder: 9749:9755 Acquire 1 refcount change on invalid ref 0 ret -22
> [   49.241979] binder: binder_mmap: 9749 205a3000-205a7000 bad vm_flags failed -1
> [   49.256949] binder: 9749:9755 unknown command 0
> [   49.262470] binder: 9749:9755 ioctl c0306201 20000fd0 returned -22
> [   49.293365] binder: 9749:9755 IncRefs 0 refcount change on invalid ref 2 ret -22
> [   49.301297] binder: binder_mmap: 9749 205a3000-205a7000 bad vm_flags failed -1
> [   49.314146] binder: 9749:9755 Acquire 1 refcount change on invalid ref 4 ret -22
> [   49.322732] binder: 9749:9755 Acquire 1 refcount change on invalid ref 0 ret -22
> [   49.332063] binder: 9749:9755 Release 1 refcount change on invalid ref 1 ret -22
> [   49.340796] binder: 9749:9755 Acquire 1 refcount change on invalid ref 2 ret -22
> [   49.349457] binder: 9749:9755 BC_DEAD_BINDER_DONE 0000000000000001 not found
> [   49.349462] binder: 9749:9755 BC_DEAD_BINDER_DONE 0000000000000000 not found
> 
> [  246.752088] INFO: task syz-executor7:10280 blocked for more than 120 seconds.
> 
> Anything that hung after uptime > 46.75 can be reported at uptime = 246.75, can't it?

Typo. I wanted to say 126.75 >= uptime > 6.75.
khungtaskd warning with 120 seconds check interval can be delayed for up to 240 seconds.

> 
> Is it possible to reproduce this problem by running the same program?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
