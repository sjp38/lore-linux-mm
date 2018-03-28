Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 899E06B0028
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 23:24:43 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id d186-v6so1352850itg.7
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 20:24:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b135-v6sor1403325itc.113.2018.03.27.20.24.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 20:24:42 -0700 (PDT)
MIME-Version: 1.0
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Wed, 28 Mar 2018 08:24:26 +0500
Message-ID: <CABXGCsOtMbRwZcyBRXWq+a2j4K7Q=JMPEC=xikrFCSqUypJyxA@mail.gmail.com>
Subject: BUG: sleeping function called from invalid context at net/core/sock.c:2768
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-bluetooth@vger.kernel.org, linux-mm@kvack.org

$ uname -r
4.16.0-rc7

[85044.650045] Bluetooth: hci0: last event is not cmd complete (0x0f)
[85057.544598] usb 1-9.2: USB disconnect, device number 12
[85060.640035] Bluetooth: hci0: last event is not cmd complete (0x0f)
[85065.025725] BUG: sleeping function called from invalid context at
net/core/sock.c:2768
[85065.025729] in_atomic(): 1, irqs_disabled(): 0, pid: 2084, name: krfcommd
[85065.025730] INFO: lockdep is turned off.
[85065.025733] CPU: 6 PID: 2084 Comm: krfcommd Not tainted 4.16.0-rc7 #1
[85065.025735] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[85065.025736] Call Trace:
[85065.025743]  dump_stack+0x85/0xbf
[85065.025747]  ___might_sleep+0x15b/0x240
[85065.025751]  lock_sock_nested+0x29/0xa0
[85065.025764]  bt_accept_enqueue+0x3c/0xb0 [bluetooth]
[85065.025770]  rfcomm_connect_ind+0x227/0x250 [rfcomm]
[85065.025774]  rfcomm_run+0x155a/0x1860 [rfcomm]
[85065.025778]  ? do_wait_intr_irq+0xb0/0xb0
[85065.025783]  ? rfcomm_check_accept+0xa0/0xa0 [rfcomm]
[85065.025786]  kthread+0x121/0x140
[85065.025789]  ? kthread_create_worker_on_cpu+0x70/0x70
[85065.025792]  ret_from_fork+0x3a/0x50
[85069.642058] Bluetooth: hci0: last event is not cmd complete (0x0f)



--
Best Regards,
Mike Gavrilov.
