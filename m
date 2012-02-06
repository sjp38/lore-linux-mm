Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 1CAE46B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:11:03 -0500 (EST)
From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: [GIT PULL 0/8] perf/core fixes and improvements
Date: Mon,  6 Feb 2012 20:10:15 -0200
Message-Id: <1328566223-27218-1-git-send-email-acme@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Anton Arapov <anton@redhat.com>, Christoph Hellwig <hch@infradead.org>, Clark Williams <williams@redhat.com>, Corey Ashford <cjashfor@linux.vnet.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, Franck Bui-Huu <fbuihuu@gmail.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Jiri Olsa <jolsa@redhat.com>, John Kacur <jkacur@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-mm <linux-mm@kvack.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Namhyung Kim <namhyung@gmail.com>, Namhyung Kim <namhyung.kim@lge.com>, Oleg Nesterov <oleg@redhat.com>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <peterz@infradead.org>, Robert Richter <robert.richter@amd.com>, Roland McGrath <roland@hack.frob.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, arnaldo.melo@gmail.com

The following changes since commit 623ec991ce0e8cd5791bad656c162fa837635907:

  Merge tag 'perf-core-for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/core (2012-01-31 13:05:08 +0100)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux perf-core-for-mingo

for you to fetch changes up to 9dac6a29e0ce0cd9dec497baa123e216b00b525d:

  perf stat: Align scaled output of cpu-clock (2012-02-06 19:17:39 -0200)

----------------------------------------------------------------
perf/core fixes and improvements.

----------------------------------------------------------------

Arnaldo Carvalho de Melo (1):
      Merge branch 'perf/urgent' into perf/core

Franck Bui-Huu (1):
      perf doc: Allow producing documentation in a specified output directory

Jiri Olsa (4):
      perf evlist: Make splice_list_tail method public
      perf tools: Fix perf stack to non executable on x86_64

John Kacur (1):
      perf tools: Remove distclean from Makefile help output

Namhyung Kim (2):
      perf stat: Adjust print unit
      perf stat: Align scaled output of cpu-clock

Robert Richter (1):
      perf record: Make feature initialization generic

Srikar Dronamraju (1):
      perf probe: Rename target_module to target

 tools/perf/Documentation/Makefile        |   86 +++++++++++++++++------------
 tools/perf/Makefile                      |    1 
 tools/perf/bench/mem-memset-x86-64-asm.S |    7 ++
 tools/perf/builtin-probe.c               |   12 ++--
 tools/perf/builtin-record.c              |   28 +++------
 tools/perf/builtin-stat.c                |    2 
 tools/perf/util/evlist.c                 |    6 +-
 tools/perf/util/evlist.h                 |    5 +
 tools/perf/util/header.h                 |    1 
 tools/perf/util/probe-event.c            |   26 ++++----
 tools/perf/builtin-stat.c                |    8 ++
 11 files changed, 105 insertions(+), 77 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
