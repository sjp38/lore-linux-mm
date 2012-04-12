Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id B4F516B00EA
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 05:29:05 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <prashanth@linux.vnet.ibm.com>;
	Thu, 12 Apr 2012 03:29:04 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id DC4EF1FF0049
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 03:28:59 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3C9T0E3186620
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 03:29:00 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3C9Svh2020775
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 03:29:00 -0600
Message-ID: <4F86A03A.1080203@linux.vnet.ibm.com>
Date: Thu, 12 Apr 2012 14:58:26 +0530
From: Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 0/2] perf/probe: verify instruction/offset in perf before
 adding a uprobe
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

This patch series is to augment Srikar's perf support for uprobes patch
(https://lkml.org/lkml/2012/4/11/191) with the following features:

a. Instruction verification for user space tracing
b. Function boundary validation support to uprobes as its kernel
counterpart (Commit-ID: 1c1bc922).

This will help in ensuring uprobe is placed at right location inside
the intended function.


--
 Prashanth Nageshappa (1):
      address build warnings/errors in insn.c
      changes to perf code to verify instruction/offset before adding uprobe


 arch/x86/lib/insn.c                    |    8 +++
 tools/perf/arch/x86/Makefile           |    4 ++
 tools/perf/arch/x86/util/probe-event.c |   83 ++++++++++++++++++++++++++++++++
 tools/perf/util/include/linux/string.h |    1 
 tools/perf/util/probe-event.c          |   22 ++++++++
 tools/perf/util/probe-event.h          |    2 +
 tools/perf/util/symbol.c               |    2 +
 tools/perf/util/symbol.h               |    1 
 8 files changed, 122 insertions(+), 1 deletions(-)
 create mode 100644 tools/perf/arch/x86/util/probe-event.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
