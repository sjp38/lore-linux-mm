Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59BCB800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 18:45:33 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y63so4347535pff.5
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 15:45:33 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 204si736440pgf.94.2018.01.24.15.45.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 15:45:32 -0800 (PST)
From: Dave Hansen <dave.hansen@intel.com>
Subject: [LSF/MM TOPIC] Meltdown Mitigation
Message-ID: <c72028c6-17f0-f585-3f10-5b005c28dcd5@intel.com>
Date: Wed, 24 Jan 2018 15:45:30 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Nicholas Piggin <npiggin@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>

There has been a lot of churn the past few months on various mitigations
for our favorite vulnerabilities.  By April, the dust should have
settled enough for us to take a look back at the impact on the VM from
all this churn.  Although a lot of action happened in arch/*, I think
there is still plenty to discuss that affects the VM.

For instance, the entry/exit paths have changed for everyone which
changes page fault behavior.  On x86, the TLB behavior is different
because of more copies of the page tables that we switch between more
frequently, in addition to the changes resulting from the PCID work[1].

powerpc/Meltdown:
	Nicholas Piggin <npiggin@gmail.com>
	Michael Ellerman <mpe@ellerman.id.au>
arm64/Meltdown:
	Will Deacon <will.deacon@arm.com>
x86/Meltdown:
	Andy Lutomirski <luto@amacapital.net>
	Thomas Gleixner <tglx@linutronix.de>
	Dave Hansen <dave.hansen@intel.com>

1.
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=660da7c9228f685b2ebe664f9fd69aaddcc420b5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
