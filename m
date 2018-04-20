Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8F76B0006
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 18:24:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c85so5319572pfb.12
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:24:11 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id p91-v6si6363907plb.457.2018.04.20.15.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 15:24:10 -0700 (PDT)
Subject: [PATCH 0/5] x86, mm: PTI Global page fixes for 4.17
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 20 Apr 2018 15:20:18 -0700
Message-Id: <20180420222018.E7646EE1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aaro.koskinen@nokia.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, fengguang.wu@intel.com, gregkh@linuxfoundation.org, hughd@google.com, mingo@kernel.org, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, torvalds@linux-foundation.org, mceier@gmail.com, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de, vbabka@suse.cz

There have been a number of reports about issues with the patches that
restore the Global PTE bit when using KPIT.  This set resolves all of
the issues that have been reported.

These have been pushed out to a git tree where 0day should be chewing
on them.  Considering the troubles thus far, we should probably wait
for 0day to spend _some_ time on these fixes before these get merged.

Cc: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Kees Cook <keescook@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mariusz Ceier <mceier@gmail.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org
