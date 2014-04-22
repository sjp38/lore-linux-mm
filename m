Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2F96B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 19:35:44 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id ih12so183899qab.11
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:35:44 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id g92si6455253qge.52.2014.04.22.16.35.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Apr 2014 16:35:44 -0700 (PDT)
Message-ID: <5356FCC1.6060807@zytor.com>
Date: Tue, 22 Apr 2014 16:35:29 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Why do we set _PAGE_DIRTY for page tables?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

I just noticed this:

#define _PAGE_TABLE     (_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |       \
                         _PAGE_ACCESSED | _PAGE_DIRTY)
#define _KERNPG_TABLE   (_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |   \
                         _PAGE_DIRTY)

Is there a reason we set _PAGE_DIRTY for page tables?  It has no
function, but doesn't do any harm either (the dirty bit is ignored for
page tables)... it just looks funny to me.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
