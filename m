Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id B1CC26B02C4
	for <linux-mm@kvack.org>; Fri,  5 May 2017 18:50:37 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h4so4196872lfj.3
        for <linux-mm@kvack.org>; Fri, 05 May 2017 15:50:37 -0700 (PDT)
Received: from mail.ispras.ru (mail.ispras.ru. [83.149.199.45])
        by mx.google.com with ESMTP id r10si3956479lfa.126.2017.05.05.15.50.35
        for <linux-mm@kvack.org>;
        Fri, 05 May 2017 15:50:36 -0700 (PDT)
From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: Is iounmap(NULL) safe or not?
Date: Sat,  6 May 2017 01:50:08 +0300
Message-Id: <1494024608-10343-1-git-send-email-khoroshilov@ispras.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org

Hello,

It seems thare are many places where code assumes iounmap(NULL) is safe.
Also there are several patches that state it explicitly:
  ff6defa6a8fa ("ALSA: Deletion of checks before the function call "iounmap")
  e24bb0ed8179 ("staging: dgnc: remove NULL test")

At the same time it seems PPC implementation generates a warning in this case:
  3bfafd6b136b ("netxen: avoid invalid iounmap")

  arch/powerpc/mm/pgtable_64.c:
	if ((unsigned long)addr < ioremap_bot) {
		printk(KERN_WARNING "Attempt to iounmap early bolted mapping"
		       " at 0x%p\n", addr);
		return;
	}

Could you please clarify if iounmap(NULL) safe or not.
I guess it would be less errorprone if the answer is architecture independent.

--
Thank you,
Alexey Khoroshilov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
