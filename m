Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id C2A6F6B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 17:36:46 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so86746592wic.1
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:36:46 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id p4si13472099wiy.6.2015.05.04.14.36.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 14:36:45 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [GIT PULL 00/21] perf/core improvements and fixes
Date: Mon,  4 May 2015 18:36:09 -0300
Message-Id: <1430775390-22523-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@kernel.org>, Adrian Hunter <adrian.hunter@intel.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, David Ahern <dsahern@gmail.com>, Frederic Weisbecker <fweisbec@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Michael Ellerman <mpe@ellerman.id.au>, Minchan Kim <minchan@kernel.org>, Namhyung Kim <namhyung@kernel.org>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Stephane Eranian <eranian@google.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Taeung Song <treeze.taeung@gmail.com>, Arnaldo Carvalho de Melo <acme@redhat.com>

Hi Ingo,

	Besides these 21 patches there are 65 other patches, all present in the
perf-core-for-mingo tag, that I sent a pull request for but had some issues
building on older distros (got reports and fixes for OL6, CentOS6, tested it
all on RHEL6), minor stuff, all noted on the comments just before my
Signed-off-by lines.

	Please consider pulling,

- Arnaldo

The following changes since commit b64aa553d8430aabd24f303899cfa4de678e2c3a:

  perf bench numa: Show more stats of particular threads in verbose mode (2015-05-04 12:43:41 -0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo-2

for you to fetch changes up to 0c160d495b5616e071bb4f873812e8f473128149:

  perf kmem: Add kmem.default config option (2015-05-04 13:34:48 -0300)

----------------------------------------------------------------
perf/core improvements and fixes:

User visible:

- perf kmem improvements: (Namhyung Kim)

  - Support sort keys on page analysis
  - New --live option
  - Humand readable gfp flags
  - Allow setting the default in perfconfig files

- perf probe --filter improvements (Masami Hiramatsu)

- Improve detection of file/function name in the 'perf probe' pattern (Naveen Rao)

Infrastructure:

- Some more Intel PT prep patches (Adrian Hunter)

- Fix ppc64 ABIv2 symbol decoding (Ananth N Mavinakayanahalli)

Build fixes:

- bison-related build failure on CentOS 6 (Namhyung Kim)

- perf probe fixes for better support powerpc (Naveen Rao)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

----------------------------------------------------------------
Adrian Hunter (3):
      perf evlist: Amend mmap ref counting for the AUX area mmap
      perf script: Always allow fields 'addr' and 'cpu' for auxtrace
      perf report: Add Instruction Tracing support

Ananth N Mavinakayanahalli (1):
      perf probe ppc64le: Fix ppc64 ABIv2 symbol decoding

Masami Hiramatsu (4):
      perf tools: Improve strfilter to append additional rules
      perf tools: Add strfilter__string to recover rules string
      perf probe: Accept multiple filter options
      perf probe: Accept filter argument for --list

Namhyung Kim (6):
      perf tools: Fix bison-related build failure on CentOS 6
      perf kmem: Implement stat --page --caller
      perf kmem: Support sort keys on page analysis
      perf kmem: Add --live option for current allocation stat
      perf kmem: Print gfp flags in human readable string
      perf kmem: Add kmem.default config option

Naveen N. Rao (7):
      perf probe ppc: Fix symbol fixup issues due to ELF type
      perf probe ppc: Use the right prefix when ignoring SyS symbols on ppc
      perf probe ppc: Enable matching against dot symbols automatically
      perf probe ppc64le: Prefer symbol table lookup over DWARF
      perf probe ppc64le: Fixup function entry if using kallsyms lookup
      perf symbols: Warn on build id mismatch
      perf probe: Improve detection of file/function name in the probe pattern

 tools/perf/Documentation/perf-kmem.txt      |  11 +-
 tools/perf/Documentation/perf-probe.txt     |   6 +-
 tools/perf/Documentation/perf-report.txt    |  27 +
 tools/perf/arch/powerpc/util/Build          |   1 +
 tools/perf/arch/powerpc/util/sym-handling.c |  82 +++
 tools/perf/builtin-kmem.c                   | 964 +++++++++++++++++++++++++---
 tools/perf/builtin-probe.c                  |  64 +-
 tools/perf/builtin-report.c                 |  11 +
 tools/perf/builtin-script.c                 |  29 +-
 tools/perf/util/Build                       |   2 +-
 tools/perf/util/evlist.c                    |   2 +-
 tools/perf/util/map.c                       |   5 +
 tools/perf/util/map.h                       |   3 +-
 tools/perf/util/probe-event.c               |  69 +-
 tools/perf/util/probe-event.h               |   5 +-
 tools/perf/util/strfilter.c                 | 107 +++
 tools/perf/util/strfilter.h                 |  35 +
 tools/perf/util/symbol-elf.c                |  13 +-
 tools/perf/util/symbol.c                    |  25 +-
 tools/perf/util/symbol.h                    |  10 +
 20 files changed, 1313 insertions(+), 158 deletions(-)
 create mode 100644 tools/perf/arch/powerpc/util/sym-handling.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
