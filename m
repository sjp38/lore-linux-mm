From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC PATCH 0/2] fast_gup for shared futexes
Date: Fri, 04 Apr 2008 21:33:32 +0200
Message-ID: <20080404193332.348493000@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760656AbYDDTjY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Hi,

this patch series removes mmap_sem from the fast path of shared futexes by
making use of Nick's recent fast_gup() patches. Full series at:

  http://programming.kicks-ass.net/kernel-patches/futex-fast_gup/v2.6.24.4-rt4/

--
