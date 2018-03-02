Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70B0C6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 15:57:42 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u36so7074576wrf.21
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 12:57:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m15sor3712071wrb.35.2018.03.02.12.57.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 12:57:41 -0800 (PST)
From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: "x86/boot/compressed/64: Prepare trampoline memory" breaks boot on
 Zotac CI-321
Message-ID: <12357ee3-0276-906a-0e7c-2c3055675af3@gmail.com>
Date: Fri, 2 Mar 2018 21:57:32 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Recently my Mini PC Zotac CI-321 started to reboot immediately before
anything was written to the console.

Bisecting lead to b91993a87aff "x86/boot/compressed/64: Prepare
trampoline memory" being the change breaking boot.

If you need any more information, please let me know.

Rgds, Heiner

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
