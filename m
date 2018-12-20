Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2EADD8E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 02:55:23 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id j10so282621wrt.11
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 23:55:23 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c18sor6339184wre.34.2018.12.19.23.55.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 23:55:21 -0800 (PST)
MIME-Version: 1.0
From: Angel Shtilianov <angel.shtilianov@siteground.com>
Date: Thu, 20 Dec 2018 09:55:10 +0200
Message-ID: <CAJM9R-JWO1P_qJzw2JboMH2dgPX7K1tF49nO5ojvf=iwGddXRQ@mail.gmail.com>
Subject: Ipmi modules and linux-4.19.1
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dennis@kernel.org, tj@kernel.org, cl@linux.com, jeyu@kernel.org

Hi everybody.
A couple of days I've decided to migrate several servers on
linux-4.19. What I've observed is that I have no /dev/ipmi. After
taking a look into the boot log I've found that ipmi modules are
complaining about percpu memory allocation failures:
https://pastebin.com/MCDssZzV
However, I've fixed my ipmi settings using older kernel, but I did
some research about the issue.
I had to increase the PERCPU_MODULE_RESERVE and PCPU_MIN_UNIT_SIZE in
order to get the ipmi modules loaded.
include/linux/percpu.h

-#define PERCPU_MODULE_RESERVE          (8 << 10)
+#define PERCPU_MODULE_RESERVE          (8 << 11)

-#define PCPU_MIN_UNIT_SIZE             PFN_ALIGN(32 << 10)
+#define PCPU_MIN_UNIT_SIZE             PFN_ALIGN(32 << 11)

-#define PERCPU_DYNAMIC_EARLY_SIZE      (12 << 10)
+#define PERCPU_DYNAMIC_EARLY_SIZE      (12 << 11)

-#define PERCPU_DYNAMIC_RESERVE         (28 << 10)
+#define PERCPU_DYNAMIC_RESERVE         (28 << 11)

Any suggestions ?
Is it a mm issue or this is a module subsystem issue ?
Shouldn't it fall back?

Best regards,
Angel Shtilianov
