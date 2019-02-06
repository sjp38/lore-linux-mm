Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33269C282CB
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 03:13:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2794217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 03:13:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2794217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=acm.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D7ED8E00A7; Tue,  5 Feb 2019 22:13:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 688BD8E001C; Tue,  5 Feb 2019 22:13:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59E0F8E00A7; Tue,  5 Feb 2019 22:13:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 054568E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 22:13:00 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id p3so3921174plk.9
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 19:12:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:mime-version:content-transfer-encoding;
        bh=jaeSUxbTiSoFIForeTq7+rIKp7+2WnpuhVvIvEC9G5M=;
        b=stpzhQyAqAAM+W/2q9Ro1nVvIKw1bGM6bdDqhPj4QJJiu3vmliTYR5nV7GUUr3gNfj
         9rZhzgER2vixCh0rRQRJP934AQp/o3XuwJSM/SYEfieo/qEqYMmnSuj9eewaYxZrm4TQ
         Ubp+PW7kS19SikxUHZ24VaXl8MC6ZGXFkvEjU0vzNQo+OYkns+lKSew8LV24TrtlLfqa
         4BB57KacR/oNNXdnAcS4OoZvP1e/K+3LakvXYfRGVGaAnBv/XP3waFX0VSjjJWcRETGu
         j9+r4sOo0UoZ+10smnjYd7urQMROB6OQQbMuj1ZggoN90BCvrEtQsk74BpFrXbPKO64/
         vbDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Gm-Message-State: AHQUAubK1aw2Ku+QHHkJnuZY9FS/4FIXtN28IBeXDfKjbfvhB7Y8A9PJ
	y2/ZlnRqz0cOy5YBuxrj7y+gjzBgha/Ai8m+dYVMoP2xbL2qJNct/+b6URYxZ1HxmmBfLn6Cnfh
	JfjAuQhcMBU35DN/L09jJ760U/OmYcgKK0fcTqKHYatPH5x+XxVRqgUsNs/3h/LTW1eS/zDX1QH
	uNS9YJbXQXM/Ibom/gInNEt7W3Us6kv4lHKoKugw1shChZabW+X9FE7yUnGZTMb5WhyX5tVHQL3
	MvQh2UO28Thax7jW7UnpWlGEj7VFW1G8AkJk1hxAjSuR8vyDtO1U3449CYUv+HvIvIpaLJRsiid
	BgkJ1gl084zv+ywamuWdTwpS5tELFSbIF6VAWNzhdU6pjPvCFGhwddzdI2pQjM48mwN90SlWqw=
	=
X-Received: by 2002:a17:902:5601:: with SMTP id h1mr8638527pli.160.1549422779508;
        Tue, 05 Feb 2019 19:12:59 -0800 (PST)
X-Received: by 2002:a17:902:5601:: with SMTP id h1mr8638428pli.160.1549422777904;
        Tue, 05 Feb 2019 19:12:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549422777; cv=none;
        d=google.com; s=arc-20160816;
        b=rB1KGR76Dmj52FKXFMRjydOwlZTV72MMlE2hoF9hr/DDOr6ajFCt7z5Dm+ayxXdmoq
         E0z442brKtQ/OsQY508nKWB2okz7FXrsaKRs9mIUDKoy9Dv4hjHZ2m4GyoXn8Gsr5bz2
         h7JRxrvHuVwk62wlTTZFH3MNCUuOtVQwMugxwJHAXb9HgNUD01YJCqnBEI9pY0o6aZOP
         yyA067mv/9H733Jxf8ikz8LJAZwPa9EQu6EoPfCCmuBl7xKbeNVcAqz/L/4nkuVyq86J
         Jz//cXR1Xi27d6u8/IopmXTrh4doTtiHdbe7IPtvfhFsWqIun8UvBZFxIKHj2DbCzSmk
         faDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:date:cc:to:from:subject
         :message-id;
        bh=jaeSUxbTiSoFIForeTq7+rIKp7+2WnpuhVvIvEC9G5M=;
        b=bKWDY4KjfoKFS8UIvoXdVm9lTmZ1mLJueOp4MuTDOFoCwAXqbV77dqMb1PDy5kZGdT
         3BSGooXQpEYEtyholzu477eJPYaxJ+T9umLk7wh8ywV7iWJsjts02C0eX+KaFAjtCw49
         xq5VgJ618y6i4I4JQSlO2sIMVYfEMPcfPi8y+YH5ggFVsx4d1CoavJmtZCX6WVpzwTX/
         lqARIzFPKZifYAh3WHTfZxrHiTSDlVmD8CufEKV/tK2QqUKrbkX5ZRxD7UYmiiP7hbSs
         kCFDJLXFM0hfRKEJ6fFtWV0UPtl9rxtBwhrjVD+nbevKV9UpdDVw7Wd2hEP3vXimxODc
         5bEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w12sor7447177plq.62.2019.02.05.19.12.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Feb 2019 19:12:57 -0800 (PST)
Received-SPF: pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Google-Smtp-Source: AHgI3IYsaUz2YBokiF/8i+gXkF5jDedCMHXTc+5hayU+4yNoYS8fDy2nhA5f3/d0HQUYv62dTD+ynQ==
X-Received: by 2002:a17:902:820f:: with SMTP id x15mr8188999pln.224.1549422777135;
        Tue, 05 Feb 2019 19:12:57 -0800 (PST)
Received: from ?IPv6:2601:647:4000:5dd1:16db:49bb:cd8e:fcf7? ([2601:647:4000:5dd1:16db:49bb:cd8e:fcf7])
        by smtp.gmail.com with ESMTPSA id l85sm7659292pfg.161.2019.02.05.19.12.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Feb 2019 19:12:56 -0800 (PST)
Message-ID: <1549422775.103781.5.camel@acm.org>
Subject: userfaultd: Possible deadlock
From: Bart Van Assche <bvanassche@acm.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
Date: Tue, 05 Feb 2019 19:12:55 -0800
Content-Type: text/plain; charset="UTF-7"
X-Mailer: Evolution 3.26.2-1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

I think that a recent commit from you introduced the syzbot complaint shown
below. Can you have a look at this?

I'm referring to commit ae62c16e105a (+ACI-userfaultfd: disable irqs when taking
the waitqueue lock+ACI). That commit went upstream in kernel v4.20.

Thanks,

Bart.

syzbot has found the following crash on:

HEAD commit:    5eeb63359b1e Merge tag 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma
git tree:       git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
console output: https://syzkaller-buganizer.googleplex.com/text?tag+AD0-CrashLog+ACY-id+AD0-abfb8cf5ee75596c3cec97fbca90007f7c572fd5
kernel config:  https://syzkaller-buganizer.googleplex.com/text?tag+AD0-Config+ACY-id+AD0-2f236acd4d07d3e9680112eeef52906988664d3b
dashboard link: https://syzkaller.appspot.com/bug?extid+AD0-554a124791d98722a022
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

See http://go/syzbot for details on how to handle this bug.

+AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQA9AD0APQ
WARNING: SOFTIRQ-safe -+AD4 SOFTIRQ-unsafe lock order detected
5.0.0-rc4+- +ACM-56 Not tainted
-----------------------------------------------------
syz-executor5/9727 +AFs-HC0+AFs-0+AF0:SC0+AFs-0+AF0:HE0:SE1+AF0 is trying to acquire:
00000000a4278d31 (+ACY-ctx-+AD4-fault+AF8-pending+AF8-wqh)+AHsAKw.+-.+AH0, at: spin+AF8-lock include/linux/spinlock.h:329 +AFs-inline+AF0
00000000a4278d31 (+ACY-ctx-+AD4-fault+AF8-pending+AF8-wqh)+AHsAKw.+-.+AH0, at: userfaultfd+AF8-ctx+AF8-read fs/userfaultfd.c:1040 +AFs-inline+AF0
00000000a4278d31 (+ACY-ctx-+AD4-fault+AF8-pending+AF8-wqh)+AHsAKw.+-.+AH0, at: userfaultfd+AF8-read+-0x540/0x1940 fs/userfaultfd.c:1198

and this task is already holding:
000000000e5b4350 (+ACY-ctx-+AD4-fd+AF8-wqh)+AHs....+AH0, at: spin+AF8-lock+AF8-irq include/linux/spinlock.h:354 +AFs-inline+AF0
000000000e5b4350 (+ACY-ctx-+AD4-fd+AF8-wqh)+AHs....+AH0, at: userfaultfd+AF8-ctx+AF8-read fs/userfaultfd.c:1036 +AFs-inline+AF0
000000000e5b4350 (+ACY-ctx-+AD4-fd+AF8-wqh)+AHs....+AH0, at: userfaultfd+AF8-read+-0x27a/0x1940 fs/userfaultfd.c:1198
which would create a new lock dependency:
 (+ACY-ctx-+AD4-fd+AF8-wqh)+AHs....+AH0 -+AD4 (+ACY-ctx-+AD4-fault+AF8-pending+AF8-wqh)+AHsAKw.+-.+AH0

but this new dependency connects a SOFTIRQ-irq-safe lock:
 (+ACY(+ACY-ctx-+AD4-ctx+AF8-lock)-+AD4-rlock)+AHs..-.+AH0

... which became SOFTIRQ-irq-safe at:
  lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
  +AF8AXw-raw+AF8-spin+AF8-lock+AF8-irq include/linux/spinlock+AF8-api+AF8-smp.h:128 +AFs-inline+AF0
  +AF8-raw+AF8-spin+AF8-lock+AF8-irq+-0x60/0x80 kernel/locking/spinlock.c:160
  spin+AF8-lock+AF8-irq include/linux/spinlock.h:354 +AFs-inline+AF0
  free+AF8-ioctx+AF8-users+-0x2d/0x4a0 fs/aio.c:610
  percpu+AF8-ref+AF8-put+AF8-many include/linux/percpu-refcount.h:285 +AFs-inline+AF0
  percpu+AF8-ref+AF8-put include/linux/percpu-refcount.h:301 +AFs-inline+AF0
  percpu+AF8-ref+AF8-call+AF8-confirm+AF8-rcu lib/percpu-refcount.c:123 +AFs-inline+AF0
  percpu+AF8-ref+AF8-switch+AF8-to+AF8-atomic+AF8-rcu+-0x3e7/0x520 lib/percpu-refcount.c:158
  +AF8AXw-rcu+AF8-reclaim kernel/rcu/rcu.h:240 +AFs-inline+AF0
  rcu+AF8-do+AF8-batch kernel/rcu/tree.c:2452 +AFs-inline+AF0
  invoke+AF8-rcu+AF8-callbacks kernel/rcu/tree.c:2773 +AFs-inline+AF0
  rcu+AF8-process+AF8-callbacks+-0x928/0x1390 kernel/rcu/tree.c:2754
  +AF8AXw-do+AF8-softirq+-0x266/0x95a kernel/softirq.c:292
  run+AF8-ksoftirqd kernel/softirq.c:654 +AFs-inline+AF0
  run+AF8-ksoftirqd+-0x8e/0x110 kernel/softirq.c:646
  smpboot+AF8-thread+AF8-fn+-0x6ab/0xa10 kernel/smpboot.c:164
  kthread+-0x357/0x430 kernel/kthread.c:246
  ret+AF8-from+AF8-fork+-0x3a/0x50 arch/x86/entry/entry+AF8-64.S:352

to a SOFTIRQ-irq-unsafe lock:
 (+ACY-ctx-+AD4-fault+AF8-pending+AF8-wqh)+AHsAKw.+-.+AH0

... which became SOFTIRQ-irq-unsafe at:
...
  lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
  +AF8AXw-raw+AF8-spin+AF8-lock include/linux/spinlock+AF8-api+AF8-smp.h:142 +AFs-inline+AF0
  +AF8-raw+AF8-spin+AF8-lock+-0x2f/0x40 kernel/locking/spinlock.c:144
  spin+AF8-lock include/linux/spinlock.h:329 +AFs-inline+AF0
  userfaultfd+AF8-release+-0x497/0x6d0 fs/userfaultfd.c:916
  +AF8AXw-fput+-0x2df/0x8d0 fs/file+AF8-table.c:278
  +AF8AXwBfAF8-fput+-0x16/0x20 fs/file+AF8-table.c:309
  task+AF8-work+AF8-run+-0x14a/0x1c0 kernel/task+AF8-work.c:113
  tracehook+AF8-notify+AF8-resume include/linux/tracehook.h:188 +AFs-inline+AF0
  exit+AF8-to+AF8-usermode+AF8-loop+-0x273/0x2c0 arch/x86/entry/common.c:166
  prepare+AF8-exit+AF8-to+AF8-usermode arch/x86/entry/common.c:197 +AFs-inline+AF0
  syscall+AF8-return+AF8-slowpath arch/x86/entry/common.c:268 +AFs-inline+AF0
  do+AF8-syscall+AF8-64+-0x52d/0x610 arch/x86/entry/common.c:293
  entry+AF8-SYSCALL+AF8-64+AF8-after+AF8-hwframe+-0x49/0xbe

other info that might help us debug this:

Chain exists of:
  +ACY(+ACY-ctx-+AD4-ctx+AF8-lock)-+AD4-rlock --+AD4 +ACY-ctx-+AD4-fd+AF8-wqh --+AD4 +ACY-ctx-+AD4-fault+AF8-pending+AF8-wqh

 Possible interrupt unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(+ACY-ctx-+AD4-fault+AF8-pending+AF8-wqh)+ADs
                               local+AF8-irq+AF8-disable()+ADs
                               lock(+ACY(+ACY-ctx-+AD4-ctx+AF8-lock)-+AD4-rlock)+ADs
                               lock(+ACY-ctx-+AD4-fd+AF8-wqh)+ADs
  +ADw-Interrupt+AD4
    lock(+ACY(+ACY-ctx-+AD4-ctx+AF8-lock)-+AD4-rlock)+ADs

 +ACoAKgAq DEADLOCK +ACoAKgAq

1 lock held by syz-executor5/9727:
 +ACM-0: 000000000e5b4350 (+ACY-ctx-+AD4-fd+AF8-wqh)+AHs....+AH0, at: spin+AF8-lock+AF8-irq include/linux/spinlock.h:354 +AFs-inline+AF0
 +ACM-0: 000000000e5b4350 (+ACY-ctx-+AD4-fd+AF8-wqh)+AHs....+AH0, at: userfaultfd+AF8-ctx+AF8-read fs/userfaultfd.c:1036 +AFs-inline+AF0
 +ACM-0: 000000000e5b4350 (+ACY-ctx-+AD4-fd+AF8-wqh)+AHs....+AH0, at: userfaultfd+AF8-read+-0x27a/0x1940 fs/userfaultfd.c:1198

the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
 -+AD4 (+ACY(+ACY-ctx-+AD4-ctx+AF8-lock)-+AD4-rlock)+AHs..-.+AH0 +AHs
    IN-SOFTIRQ-W at:
                      lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
                      +AF8AXw-raw+AF8-spin+AF8-lock+AF8-irq include/linux/spinlock+AF8-api+AF8-smp.h:128 +AFs-inline+AF0
                      +AF8-raw+AF8-spin+AF8-lock+AF8-irq+-0x60/0x80 kernel/locking/spinlock.c:160
                      spin+AF8-lock+AF8-irq include/linux/spinlock.h:354 +AFs-inline+AF0
                      free+AF8-ioctx+AF8-users+-0x2d/0x4a0 fs/aio.c:610
                      percpu+AF8-ref+AF8-put+AF8-many include/linux/percpu-refcount.h:285 +AFs-inline+AF0
                      percpu+AF8-ref+AF8-put include/linux/percpu-refcount.h:301 +AFs-inline+AF0
                      percpu+AF8-ref+AF8-call+AF8-confirm+AF8-rcu lib/percpu-refcount.c:123 +AFs-inline+AF0
                      percpu+AF8-ref+AF8-switch+AF8-to+AF8-atomic+AF8-rcu+-0x3e7/0x520 lib/percpu-refcount.c:158
                      +AF8AXw-rcu+AF8-reclaim kernel/rcu/rcu.h:240 +AFs-inline+AF0
                      rcu+AF8-do+AF8-batch kernel/rcu/tree.c:2452 +AFs-inline+AF0
                      invoke+AF8-rcu+AF8-callbacks kernel/rcu/tree.c:2773 +AFs-inline+AF0
                      rcu+AF8-process+AF8-callbacks+-0x928/0x1390 kernel/rcu/tree.c:2754
                      +AF8AXw-do+AF8-softirq+-0x266/0x95a kernel/softirq.c:292
                      run+AF8-ksoftirqd kernel/softirq.c:654 +AFs-inline+AF0
                      run+AF8-ksoftirqd+-0x8e/0x110 kernel/softirq.c:646
                      smpboot+AF8-thread+AF8-fn+-0x6ab/0xa10 kernel/smpboot.c:164
                      kthread+-0x357/0x430 kernel/kthread.c:246
                      ret+AF8-from+AF8-fork+-0x3a/0x50 arch/x86/entry/entry+AF8-64.S:352
    INITIAL USE at:
                     lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
                     +AF8AXw-raw+AF8-spin+AF8-lock+AF8-irq include/linux/spinlock+AF8-api+AF8-smp.h:128 +AFs-inline+AF0
                     +AF8-raw+AF8-spin+AF8-lock+AF8-irq+-0x60/0x80 kernel/locking/spinlock.c:160
                     spin+AF8-lock+AF8-irq include/linux/spinlock.h:354 +AFs-inline+AF0
                     free+AF8-ioctx+AF8-users+-0x2d/0x4a0 fs/aio.c:610
                     percpu+AF8-ref+AF8-put+AF8-many include/linux/percpu-refcount.h:285 +AFs-inline+AF0
                     percpu+AF8-ref+AF8-put include/linux/percpu-refcount.h:301 +AFs-inline+AF0
                     percpu+AF8-ref+AF8-call+AF8-confirm+AF8-rcu lib/percpu-refcount.c:123 +AFs-inline+AF0
                     percpu+AF8-ref+AF8-switch+AF8-to+AF8-atomic+AF8-rcu+-0x3e7/0x520 lib/percpu-refcount.c:158
                     +AF8AXw-rcu+AF8-reclaim kernel/rcu/rcu.h:240 +AFs-inline+AF0
                     rcu+AF8-do+AF8-batch kernel/rcu/tree.c:2452 +AFs-inline+AF0
                     invoke+AF8-rcu+AF8-callbacks kernel/rcu/tree.c:2773 +AFs-inline+AF0
                     rcu+AF8-process+AF8-callbacks+-0x928/0x1390 kernel/rcu/tree.c:2754
                     +AF8AXw-do+AF8-softirq+-0x266/0x95a kernel/softirq.c:292
                     run+AF8-ksoftirqd kernel/softirq.c:654 +AFs-inline+AF0
                     run+AF8-ksoftirqd+-0x8e/0x110 kernel/softirq.c:646
                     smpboot+AF8-thread+AF8-fn+-0x6ab/0xa10 kernel/smpboot.c:164
                     kthread+-0x357/0x430 kernel/kthread.c:246
                     ret+AF8-from+AF8-fork+-0x3a/0x50 arch/x86/entry/entry+AF8-64.S:352
  +AH0
  ... key      at: +AFsAPA-ffffffff8a5760a0+AD4AXQ +AF8AXw-key.51972+-0x0/0x40
  ... acquired at:
   +AF8AXw-raw+AF8-spin+AF8-lock include/linux/spinlock+AF8-api+AF8-smp.h:142 +AFs-inline+AF0
   +AF8-raw+AF8-spin+AF8-lock+-0x2f/0x40 kernel/locking/spinlock.c:144
   spin+AF8-lock include/linux/spinlock.h:329 +AFs-inline+AF0
   aio+AF8-poll fs/aio.c:1772 +AFs-inline+AF0
   +AF8AXw-io+AF8-submit+AF8-one fs/aio.c:1875 +AFs-inline+AF0
   io+AF8-submit+AF8-one+-0xedf/0x1cf0 fs/aio.c:1908
   +AF8AXw-do+AF8-sys+AF8-io+AF8-submit fs/aio.c:1953 +AFs-inline+AF0
   +AF8AXw-se+AF8-sys+AF8-io+AF8-submit fs/aio.c:1923 +AFs-inline+AF0
   +AF8AXw-x64+AF8-sys+AF8-io+AF8-submit+-0x1bd/0x580 fs/aio.c:1923
   do+AF8-syscall+AF8-64+-0x103/0x610 arch/x86/entry/common.c:290
   entry+AF8-SYSCALL+AF8-64+AF8-after+AF8-hwframe+-0x49/0xbe

-+AD4 (+ACY-ctx-+AD4-fd+AF8-wqh)+AHs....+AH0 +AHs
   INITIAL USE at:
                   lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
                   +AF8AXw-raw+AF8-spin+AF8-lock+AF8-irqsave include/linux/spinlock+AF8-api+AF8-smp.h:110 +AFs-inline+AF0
                   +AF8-raw+AF8-spin+AF8-lock+AF8-irqsave+-0x95/0xcd kernel/locking/spinlock.c:152
                   +AF8AXw-wake+AF8-up+AF8-common+AF8-lock+-0xc7/0x190 kernel/sched/wait.c:120
                   +AF8AXw-wake+AF8-up+-0xe/0x10 kernel/sched/wait.c:145
                   userfaultfd+AF8-release+-0x4f5/0x6d0 fs/userfaultfd.c:924
                   +AF8AXw-fput+-0x2df/0x8d0 fs/file+AF8-table.c:278
                   +AF8AXwBfAF8-fput+-0x16/0x20 fs/file+AF8-table.c:309
                   task+AF8-work+AF8-run+-0x14a/0x1c0 kernel/task+AF8-work.c:113
                   tracehook+AF8-notify+AF8-resume include/linux/tracehook.h:188 +AFs-inline+AF0
                   exit+AF8-to+AF8-usermode+AF8-loop+-0x273/0x2c0 arch/x86/entry/common.c:166
                   prepare+AF8-exit+AF8-to+AF8-usermode arch/x86/entry/common.c:197 +AFs-inline+AF0
                   syscall+AF8-return+AF8-slowpath arch/x86/entry/common.c:268 +AFs-inline+AF0
                   do+AF8-syscall+AF8-64+-0x52d/0x610 arch/x86/entry/common.c:293
                   entry+AF8-SYSCALL+AF8-64+AF8-after+AF8-hwframe+-0x49/0xbe
 +AH0
 ... key      at: +AFsAPA-ffffffff8a575e20+AD4AXQ +AF8AXw-key.44854+-0x0/0x40
 ... acquired at:
   lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
   +AF8AXw-raw+AF8-spin+AF8-lock include/linux/spinlock+AF8-api+AF8-smp.h:142 +AFs-inline+AF0
   +AF8-raw+AF8-spin+AF8-lock+-0x2f/0x40 kernel/locking/spinlock.c:144
   spin+AF8-lock include/linux/spinlock.h:329 +AFs-inline+AF0
   userfaultfd+AF8-ctx+AF8-read fs/userfaultfd.c:1040 +AFs-inline+AF0
   userfaultfd+AF8-read+-0x540/0x1940 fs/userfaultfd.c:1198
   +AF8AXw-vfs+AF8-read+-0x116/0x8c0 fs/read+AF8-write.c:416
   vfs+AF8-read+-0x194/0x3e0 fs/read+AF8-write.c:452
   ksys+AF8-read+-0xea/0x1f0 fs/read+AF8-write.c:578
   +AF8AXw-do+AF8-sys+AF8-read fs/read+AF8-write.c:588 +AFs-inline+AF0
   +AF8AXw-se+AF8-sys+AF8-read fs/read+AF8-write.c:586 +AFs-inline+AF0
   +AF8AXw-x64+AF8-sys+AF8-read+-0x73/0xb0 fs/read+AF8-write.c:586
   do+AF8-syscall+AF8-64+-0x103/0x610 arch/x86/entry/common.c:290
   entry+AF8-SYSCALL+AF8-64+AF8-after+AF8-hwframe+-0x49/0xbe


the dependencies between the lock to be acquired
 and SOFTIRQ-irq-unsafe lock:
-+AD4 (+ACY-ctx-+AD4-fault+AF8-pending+AF8-wqh)+AHsAKw.+-.+AH0 +AHs
   HARDIRQ-ON-W at:
                    lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
                    +AF8AXw-raw+AF8-spin+AF8-lock include/linux/spinlock+AF8-api+AF8-smp.h:142 +AFs-inline+AF0
                    +AF8-raw+AF8-spin+AF8-lock+-0x2f/0x40 kernel/locking/spinlock.c:144
                    spin+AF8-lock include/linux/spinlock.h:329 +AFs-inline+AF0
                    userfaultfd+AF8-release+-0x497/0x6d0 fs/userfaultfd.c:916
                    +AF8AXw-fput+-0x2df/0x8d0 fs/file+AF8-table.c:278
                    +AF8AXwBfAF8-fput+-0x16/0x20 fs/file+AF8-table.c:309
                    task+AF8-work+AF8-run+-0x14a/0x1c0 kernel/task+AF8-work.c:113
                    tracehook+AF8-notify+AF8-resume include/linux/tracehook.h:188 +AFs-inline+AF0
                    exit+AF8-to+AF8-usermode+AF8-loop+-0x273/0x2c0 arch/x86/entry/common.c:166
                    prepare+AF8-exit+AF8-to+AF8-usermode arch/x86/entry/common.c:197 +AFs-inline+AF0
                    syscall+AF8-return+AF8-slowpath arch/x86/entry/common.c:268 +AFs-inline+AF0
                    do+AF8-syscall+AF8-64+-0x52d/0x610 arch/x86/entry/common.c:293
                    entry+AF8-SYSCALL+AF8-64+AF8-after+AF8-hwframe+-0x49/0xbe
   SOFTIRQ-ON-W at:
                    lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
                    +AF8AXw-raw+AF8-spin+AF8-lock include/linux/spinlock+AF8-api+AF8-smp.h:142 +AFs-inline+AF0
                    +AF8-raw+AF8-spin+AF8-lock+-0x2f/0x40 kernel/locking/spinlock.c:144
                    spin+AF8-lock include/linux/spinlock.h:329 +AFs-inline+AF0
                    userfaultfd+AF8-release+-0x497/0x6d0 fs/userfaultfd.c:916
                    +AF8AXw-fput+-0x2df/0x8d0 fs/file+AF8-table.c:278
                    +AF8AXwBfAF8-fput+-0x16/0x20 fs/file+AF8-table.c:309
                    task+AF8-work+AF8-run+-0x14a/0x1c0 kernel/task+AF8-work.c:113
                    tracehook+AF8-notify+AF8-resume include/linux/tracehook.h:188 +AFs-inline+AF0
                    exit+AF8-to+AF8-usermode+AF8-loop+-0x273/0x2c0 arch/x86/entry/common.c:166
                    prepare+AF8-exit+AF8-to+AF8-usermode arch/x86/entry/common.c:197 +AFs-inline+AF0
                    syscall+AF8-return+AF8-slowpath arch/x86/entry/common.c:268 +AFs-inline+AF0
                    do+AF8-syscall+AF8-64+-0x52d/0x610 arch/x86/entry/common.c:293
                    entry+AF8-SYSCALL+AF8-64+AF8-after+AF8-hwframe+-0x49/0xbe
   INITIAL USE at:
                   lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
                   +AF8AXw-raw+AF8-spin+AF8-lock include/linux/spinlock+AF8-api+AF8-smp.h:142 +AFs-inline+AF0
                   +AF8-raw+AF8-spin+AF8-lock+-0x2f/0x40 kernel/locking/spinlock.c:144
                   spin+AF8-lock include/linux/spinlock.h:329 +AFs-inline+AF0
                   userfaultfd+AF8-release+-0x497/0x6d0 fs/userfaultfd.c:916
                   +AF8AXw-fput+-0x2df/0x8d0 fs/file+AF8-table.c:278
                   +AF8AXwBfAF8-fput+-0x16/0x20 fs/file+AF8-table.c:309
                   task+AF8-work+AF8-run+-0x14a/0x1c0 kernel/task+AF8-work.c:113
                   tracehook+AF8-notify+AF8-resume include/linux/tracehook.h:188 +AFs-inline+AF0
                   exit+AF8-to+AF8-usermode+AF8-loop+-0x273/0x2c0 arch/x86/entry/common.c:166
                   prepare+AF8-exit+AF8-to+AF8-usermode arch/x86/entry/common.c:197 +AFs-inline+AF0
                   syscall+AF8-return+AF8-slowpath arch/x86/entry/common.c:268 +AFs-inline+AF0
                   do+AF8-syscall+AF8-64+-0x52d/0x610 arch/x86/entry/common.c:293
                   entry+AF8-SYSCALL+AF8-64+AF8-after+AF8-hwframe+-0x49/0xbe
 +AH0
 ... key      at: +AFsAPA-ffffffff8a575ee0+AD4AXQ +AF8AXw-key.44851+-0x0/0x40
 ... acquired at:
   lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
   +AF8AXw-raw+AF8-spin+AF8-lock include/linux/spinlock+AF8-api+AF8-smp.h:142 +AFs-inline+AF0
   +AF8-raw+AF8-spin+AF8-lock+-0x2f/0x40 kernel/locking/spinlock.c:144
   spin+AF8-lock include/linux/spinlock.h:329 +AFs-inline+AF0
   userfaultfd+AF8-ctx+AF8-read fs/userfaultfd.c:1040 +AFs-inline+AF0
   userfaultfd+AF8-read+-0x540/0x1940 fs/userfaultfd.c:1198
   +AF8AXw-vfs+AF8-read+-0x116/0x8c0 fs/read+AF8-write.c:416
   vfs+AF8-read+-0x194/0x3e0 fs/read+AF8-write.c:452
   ksys+AF8-read+-0xea/0x1f0 fs/read+AF8-write.c:578
   +AF8AXw-do+AF8-sys+AF8-read fs/read+AF8-write.c:588 +AFs-inline+AF0
   +AF8AXw-se+AF8-sys+AF8-read fs/read+AF8-write.c:586 +AFs-inline+AF0
   +AF8AXw-x64+AF8-sys+AF8-read+-0x73/0xb0 fs/read+AF8-write.c:586
   do+AF8-syscall+AF8-64+-0x103/0x610 arch/x86/entry/common.c:290
   entry+AF8-SYSCALL+AF8-64+AF8-after+AF8-hwframe+-0x49/0xbe


stack backtrace:
CPU: 1 PID: 9727 Comm: syz-executor5 Not tainted 5.0.0-rc4+- +ACM-56
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
Call Trace:
 +AF8AXw-dump+AF8-stack lib/dump+AF8-stack.c:77 +AFs-inline+AF0
 dump+AF8-stack+-0x172/0x1f0 lib/dump+AF8-stack.c:113
 print+AF8-bad+AF8-irq+AF8-dependency kernel/locking/lockdep.c:1573 +AFs-inline+AF0
 check+AF8-usage.cold+-0x60f/0x940 kernel/locking/lockdep.c:1605
 check+AF8-irq+AF8-usage kernel/locking/lockdep.c:1661 +AFs-inline+AF0
 check+AF8-prev+AF8-add+AF8-irq kernel/locking/lockdep+AF8-states.h:8 +AFs-inline+AF0
 check+AF8-prev+AF8-add kernel/locking/lockdep.c:1871 +AFs-inline+AF0
 check+AF8-prevs+AF8-add kernel/locking/lockdep.c:1979 +AFs-inline+AF0
 validate+AF8-chain kernel/locking/lockdep.c:2350 +AFs-inline+AF0
 +AF8AXw-lock+AF8-acquire+-0x1f47/0x4700 kernel/locking/lockdep.c:3338
 lock+AF8-acquire+-0x16f/0x3f0 kernel/locking/lockdep.c:3841
 +AF8AXw-raw+AF8-spin+AF8-lock include/linux/spinlock+AF8-api+AF8-smp.h:142 +AFs-inline+AF0
 +AF8-raw+AF8-spin+AF8-lock+-0x2f/0x40 kernel/locking/spinlock.c:144
 spin+AF8-lock include/linux/spinlock.h:329 +AFs-inline+AF0
 userfaultfd+AF8-ctx+AF8-read fs/userfaultfd.c:1040 +AFs-inline+AF0
 userfaultfd+AF8-read+-0x540/0x1940 fs/userfaultfd.c:1198
 +AF8AXw-vfs+AF8-read+-0x116/0x8c0 fs/read+AF8-write.c:416
 vfs+AF8-read+-0x194/0x3e0 fs/read+AF8-write.c:452
 ksys+AF8-read+-0xea/0x1f0 fs/read+AF8-write.c:578
 +AF8AXw-do+AF8-sys+AF8-read fs/read+AF8-write.c:588 +AFs-inline+AF0
 +AF8AXw-se+AF8-sys+AF8-read fs/read+AF8-write.c:586 +AFs-inline+AF0
 +AF8AXw-x64+AF8-sys+AF8-read+-0x73/0xb0 fs/read+AF8-write.c:586
 do+AF8-syscall+AF8-64+-0x103/0x610 arch/x86/entry/common.c:290
 entry+AF8-SYSCALL+AF8-64+AF8-after+AF8-hwframe+-0x49/0xbe

