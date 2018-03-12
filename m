Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 71E096B0003
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 06:02:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j12so5519617pff.18
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 03:02:58 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b66si3050064pgc.148.2018.03.12.03.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 03:02:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/4] x86/boot/compressed/64: Switch between paging modes using trampoline
Date: Mon, 12 Mar 2018 13:02:42 +0300
Message-Id: <20180312100246.89175-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patchset changes kernel decompression code to use trampoline to
switch between paging modes.

The patchset is replacement for previously reverted patch "Handle 5-level
paging boot if kernel is above 4G".

Please review and consider applying.

Kirill A. Shutemov (4):
  x86/boot/compressed/64: Make sure we have 32-bit code segment
  x86/boot/compressed/64: Use stack from trampoline memory
  x86/boot/compressed/64: Use page table in trampoline memory
  x86/boot/compressed/64: Handle 5-level paging boot if kernel is above 4G

 arch/x86/boot/compressed/head_64.S | 128 ++++++++++++++++++++++++++-----------
 1 file changed, 90 insertions(+), 38 deletions(-)

-- 
2.16.1
