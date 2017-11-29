Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D81E6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:25:55 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 88so862536pla.14
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 22:25:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33sor438219ply.83.2017.11.28.22.25.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 22:25:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171128223041.GZ3624@linux.vnet.ibm.com>
References: <94eb2c03c9bcc3b127055f11171d@google.com> <20171128133026.cf03471c99d7a0c827c5a21c@linux-foundation.org>
 <20171128223041.GZ3624@linux.vnet.ibm.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 29 Nov 2017 07:25:32 +0100
Message-ID: <CACT4Y+YLi5qw1z4t4greG05n_2NL3mpXjhT7F-Kh-YeN4HWC3g@mail.gmail.com>
Subject: Re: WARNING: suspicious RCU usage (3)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, syzbot <bot+73a7bec1bc0f4fc0512a246334081f8c671762a8@syzkaller.appspotmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs@googlegroups.com, Herbert Xu <herbert@gondor.apana.org.au>

On Tue, Nov 28, 2017 at 11:30 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Tue, Nov 28, 2017 at 01:30:26PM -0800, Andrew Morton wrote:
>> On Tue, 28 Nov 2017 12:45:01 -0800 syzbot <bot+73a7bec1bc0f4fc0512a246334081f8c671762a8@syzkaller.appspotmail.com> wrote:
>>
>> > Hello,
>> >
>> > syzkaller hit the following crash on
>> > b0a84f19a5161418d4360cd57603e94ed489915e
>> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
>> > compiler: gcc (GCC) 7.1.1 20170620
>> > .config is attached
>> > Raw console output is attached.
>> >
>> > Unfortunately, I don't have any reproducer for this bug yet.
>> >
>> > WARNING: suspicious RCU usage
>>
>> There's a bunch of other info which lockdep_rcu_suspicious() should
>> have printed out, but this trace doesn't have any of it.  I wonder why.
>
> Yes, there should be more info printed, no idea why it would go missing.

I think that's because while reporting "suspicious RCU usage" kernel hit:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000074

and the rest of the report is actually about the NULL deref.

syzkaller hits too many crashes at the same time. And it's a problem
for us. We get reports with corrupted/intermixed titles,
corrupted/intermixed bodies, reports with same titles but about
different bugs, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
