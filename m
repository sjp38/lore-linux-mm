Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 813776B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 17:30:48 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id f91so926035qkf.2
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 14:30:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e187si276231qkd.238.2017.11.28.14.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 14:30:47 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vASMUP2K002169
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 17:30:46 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ehbb2xuyq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 17:30:45 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 28 Nov 2017 17:30:44 -0500
Date: Tue, 28 Nov 2017 14:30:41 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: WARNING: suspicious RCU usage (3)
Reply-To: paulmck@linux.vnet.ibm.com
References: <94eb2c03c9bcc3b127055f11171d@google.com>
 <20171128133026.cf03471c99d7a0c827c5a21c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128133026.cf03471c99d7a0c827c5a21c@linux-foundation.org>
Message-Id: <20171128223041.GZ3624@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <bot+73a7bec1bc0f4fc0512a246334081f8c671762a8@syzkaller.appspotmail.com>, cl@linux.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, syzkaller-bugs@googlegroups.com, Herbert Xu <herbert@gondor.apana.org.au>

On Tue, Nov 28, 2017 at 01:30:26PM -0800, Andrew Morton wrote:
> On Tue, 28 Nov 2017 12:45:01 -0800 syzbot <bot+73a7bec1bc0f4fc0512a246334081f8c671762a8@syzkaller.appspotmail.com> wrote:
> 
> > Hello,
> > 
> > syzkaller hit the following crash on  
> > b0a84f19a5161418d4360cd57603e94ed489915e
> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> > compiler: gcc (GCC) 7.1.1 20170620
> > .config is attached
> > Raw console output is attached.
> > 
> > Unfortunately, I don't have any reproducer for this bug yet.
> > 
> > WARNING: suspicious RCU usage
> 
> There's a bunch of other info which lockdep_rcu_suspicious() should
> have printed out, but this trace doesn't have any of it.  I wonder why.

Yes, there should be more info printed, no idea why it would go missing.

							Thanx, Paul

> > 4.14.0-next-20171127+ #53 Not tainted
> > BUG: unable to handle kernel NULL pointer dereference at 0000000000000074
> > IP: virt_to_cache mm/slab.c:400 [inline]
> > IP: kfree+0xb2/0x250 mm/slab.c:3803
> > PGD 1cd9be067 P4D 1cd9be067 PUD 1c646d067 PMD 0
> > Oops: 0000 [#1] SMP KASAN
> > Dumping ftrace buffer:
> >     (ftrace buffer empty)
> > Modules linked in:
> > CPU: 1 PID: 17319 Comm: syz-executor7 Not tainted 4.14.0-next-20171127+ #53
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> > Google 01/01/2011
> > task: ffff8801c5442040 task.stack: ffff8801c7ed8000
> > RIP: 0010:virt_to_cache mm/slab.c:400 [inline]
> > RIP: 0010:kfree+0xb2/0x250 mm/slab.c:3803
> > RSP: 0018:ffff8801c7edf780 EFLAGS: 00010046
> > RAX: 0000000000000000 RBX: ffff8801c7edf948 RCX: ffffffffffffffff
> > RDX: ffffea00071fb7c0 RSI: 0000000000000000 RDI: ffff8801c7edf948
> > RBP: ffff8801c7edf7a0 R08: ffffed003b02866c R09: 0000000000000000
> > R10: 0000000000000001 R11: ffffed003b02866b R12: 0000000000000286
> > R13: 0000000000000000 R14: ffff8801c7edf948 R15: ffff8801c7edf8b0
> > FS:  00007ff14d179700(0000) GS:ffff8801db500000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000000000000074 CR3: 00000001c6768000 CR4: 00000000001426e0
> > Call Trace:
> >   blkcipher_walk_done+0x72b/0xde0 crypto/blkcipher.c:139
> >   encrypt+0x50a/0xaf0 crypto/salsa20_generic.c:208
> >   skcipher_crypt_blkcipher crypto/skcipher.c:622 [inline]
> >   skcipher_encrypt_blkcipher+0x213/0x310 crypto/skcipher.c:631
> >   crypto_skcipher_encrypt include/crypto/skcipher.h:445 [inline]
> >   _skcipher_recvmsg crypto/algif_skcipher.c:144 [inline]
> >   skcipher_recvmsg+0x9e8/0xf20 crypto/algif_skcipher.c:165
> >   sock_recvmsg_nosec net/socket.c:805 [inline]
> >   sock_recvmsg+0xc9/0x110 net/socket.c:812
> >   ___sys_recvmsg+0x29b/0x630 net/socket.c:2207
> >   __sys_recvmsg+0xe2/0x210 net/socket.c:2252
> >   SYSC_recvmsg net/socket.c:2264 [inline]
> >   SyS_recvmsg+0x2d/0x50 net/socket.c:2259
> >   entry_SYSCALL_64_fastpath+0x1f/0x96
> 
> It looks like blkcipher_walk_done() passed a bad address to kfree().
> 
> > RIP: 0033:0x4529d9
> > RSP: 002b:00007ff14d178c58 EFLAGS: 00000212 ORIG_RAX: 000000000000002f
> > RAX: ffffffffffffffda RBX: 0000000000758190 RCX: 00000000004529d9
> > RDX: 0000000000010000 RSI: 0000000020d63fc8 RDI: 0000000000000018
> > RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
> > R10: 0000000000000000 R11: 0000000000000212 R12: 00000000006f2728
> > R13: 00000000ffffffff R14: 00007ff14d1796d4 R15: 0000000000000000
> > Code: c2 48 b8 00 00 00 00 00 ea ff ff 48 89 df 48 c1 ea 0c 48 c1 e2 06 48  
> > 01 c2 48 8b 42 20 48 8d 48 ff a8 01 48 0f 45 d1 4c 8b 6a 30 <49> 63 75 74  
> > e8 b5 5c af ff 48 89 de 4c 89 ef 4c 8b 75 08 e8 76
> > RIP: virt_to_cache mm/slab.c:400 [inline] RSP: ffff8801c7edf780
> > RIP: kfree+0xb2/0x250 mm/slab.c:3803 RSP: ffff8801c7edf780
> > CR2: 0000000000000074
> > ---[ end trace e3c719a9c9d01886 ]---
> > 
> > 
> > ---
> > This bug is generated by a dumb bot. It may contain errors.
> > See https://urldefense.proofpoint.com/v2/url?u=https-3A__goo.gl_tpsmEJ&d=DwICAg&c=jf_iaSHvJObTbx-siA1ZOg&r=q4hkQkeaNH3IlTsPvEwkaUALMqf7y6jCMwT5b6lVQbQ&m=aTCoRUwymtfv220QJqsca2w9mocNKMrzqpgtUF-s558&s=2sG5vQqYSKlZIxmT377N3IAs1G31yBEQVetU4JSSt34&e= for details.
> > Direct all questions to syzkaller@googlegroups.com.
> > Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
> > 
> > syzbot will keep track of this bug report.
> > Once a fix for this bug is committed, please reply to this email with:
> > #syz fix: exact-commit-title
> > To mark this as a duplicate of another syzbot report, please reply with:
> > #syz dup: exact-subject-of-another-report
> > If it's a one-off invalid bug report, please reply with:
> > #syz invalid
> > Note: if the crash happens again, it will cause creation of a new bug  
> > report.
> > Note: all commands must start from beginning of the line in the email body.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
