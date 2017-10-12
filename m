Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 46B296B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 16:04:28 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k4so4027875wmc.20
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 13:04:28 -0700 (PDT)
Received: from demfloro.ru (demfloro.ru. [188.166.0.225])
        by mx.google.com with ESMTPS id n15si931169edl.98.2017.10.12.13.04.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Oct 2017 13:04:25 -0700 (PDT)
Date: Thu, 12 Oct 2017 23:01:24 +0300
From: Dmitrii Tcvetkov <demfloro@demfloro.ru>
Subject: Kernel freeze on AMD FX-9590 CPU during I/O
Message-ID: <20171012230124.32550187@demfloro.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

Since linux kernel 4.14-rc1 almost any I/O has a chance to freeze kernel
(no log in /dev/tty0 nor /dev/ttyS0 not netconsole, no ARP answer over
network) on one of my machines. Compiling linux kernel reproduces the
issue reliably so far.

Bisecting between v4.13 and v4.14-rc1 led me to commit
94b1b03b519b81c494900cb112aa00ed205cc2d9
Also I created a bug in bugzilla, bisect log is attached there:
https://bugzilla.kernel.org/show_bug.cgi?id=197209

Unfortunately I can't test reverting of the commit on current mainline
due to revert conflicts and I don't know how to resolve them correctly.

My machine:
CPU: AMD FX-9590
RAM: non-ECC DDR 12 Gb
Storage layout: btrfs on top LVM on top LUKS on top HDD

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
