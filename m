Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0D26F6B006C
	for <linux-mm@kvack.org>; Tue,  5 May 2015 17:32:38 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so197909916wgy.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 14:32:37 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ba3si30468020wjc.86.2015.05.05.14.32.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 14:32:36 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [GIT PULL 00/25] perf/core improvements and fixes
Date: Tue,  5 May 2015 18:31:54 -0300
Message-Id: <1430861539-30518-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@kernel.org>, Adrian Hunter <adrian.hunter@intel.com>, David Ahern <dsahern@gmail.com>, Frederic Weisbecker <fweisbec@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Minchan Kim <minchan@kernel.org>, Namhyung Kim <namhyung@kernel.org>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Stephane Eranian <eranian@google.com>, Arnaldo Carvalho de Melo <acme@redhat.com>

Hi Ingo,

	Please consider applying, on top of previous requests,

- Arnaldo

The following changes since commit 0c160d495b5616e071bb4f873812e8f473128149:

  perf kmem: Add kmem.default config option (2015-05-04 13:34:48 -0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux.git tags/perf-core-for-mingo-3

for you to fetch changes up to 3698dab1c849c7e1cd440df4fca24baa1973d53b:

  perf tools: Move TUI-specific fields out of map_symbol (2015-05-05 18:13:24 -0300)

----------------------------------------------------------------
perf/core improvements and fixes:

User visible:

- Improve --filter support for 'perf probe', allowing using its arguments
  on other commands, as --add, --del, etc (Masami Hiramatsu)

- Show warning when running 'perf kmem stat' on a unsuitable perf.data file,
  i.e. one with events that are not the ones required for the stat variant
  used (Namhyung Kim).

Infrastructure:

- Auxtrace support patches, paving the way to support Intel PT and BTS (Adrian Hunter)

- hists browser (top, report) refactorings (Namhyung Kim)

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

----------------------------------------------------------------
Adrian Hunter (9):
      perf report: Fix placement of itrace option in documentation
      perf tools: Add AUX area tracing index
      perf tools: Hit all build ids when AUX area tracing
      perf tools: Add build option NO_AUXTRACE to exclude AUX area tracing
      perf auxtrace: Add option to synthesize events for transactions
      perf tools: Add support for PERF_RECORD_AUX
      perf tools: Add support for PERF_RECORD_ITRACE_START
      perf tools: Add AUX area tracing Snapshot Mode
      perf record: Add AUX area tracing Snapshot Mode support

Masami Hiramatsu (4):
      perf probe: Allow to use filter on --del command
      perf probe: Accept filter argument for --funcs
      perf probe: Remove redundant cleanup of params.filter
      perf probe: Cleanup and consolidate command parsers

Namhyung Kim (12):
      perf kmem: Show warning when trying to run stat without record
      perf tools: Move TUI-specific fields into unnamed union
      perf tools: Move init_have_children field to the unnamed union
      perf hists browser: Fix possible memory leak
      perf hists browser: Save hist_browser_timer pointer in hist_browser
      perf hists browser: Save pstack in the hist_browser
      perf hists browser: Save perf_session_env in the hist_browser
      perf hists browser: Split popup menu actions
      perf hists browser: Split popup menu actions - part 2
      perf tools: Introduce pstack_peek()
      perf hists browser: Simplify zooming code using pstack_peek()
      perf tools: Move TUI-specific fields out of map_symbol

 tools/perf/Documentation/perf-inject.txt |   9 +-
 tools/perf/Documentation/perf-probe.txt  |   3 +-
 tools/perf/Documentation/perf-record.txt |   7 +
 tools/perf/Documentation/perf-report.txt |  15 +-
 tools/perf/Documentation/perf-script.txt |   9 +-
 tools/perf/Makefile.perf                 |   2 +
 tools/perf/builtin-buildid-list.c        |   9 +
 tools/perf/builtin-inject.c              |  78 +++-
 tools/perf/builtin-kmem.c                |  17 +-
 tools/perf/builtin-probe.c               | 133 +++----
 tools/perf/builtin-record.c              | 172 ++++++++-
 tools/perf/config/Makefile               |   5 +
 tools/perf/perf.h                        |   3 +
 tools/perf/tests/make                    |   4 +-
 tools/perf/ui/browsers/hists.c           | 633 +++++++++++++++++++------------
 tools/perf/util/Build                    |   2 +-
 tools/perf/util/auxtrace.c               | 305 ++++++++++++++-
 tools/perf/util/auxtrace.h               | 217 +++++++++++
 tools/perf/util/callchain.h              |   4 +
 tools/perf/util/event.c                  |  39 ++
 tools/perf/util/event.h                  |  24 ++
 tools/perf/util/header.c                 |  31 +-
 tools/perf/util/hist.c                   |   2 +-
 tools/perf/util/machine.c                |  21 +
 tools/perf/util/machine.h                |   4 +
 tools/perf/util/parse-options.h          |   4 +
 tools/perf/util/probe-event.c            | 102 ++---
 tools/perf/util/probe-event.h            |   2 +-
 tools/perf/util/pstack.c                 |   7 +
 tools/perf/util/pstack.h                 |   1 +
 tools/perf/util/session.c                |  32 ++
 tools/perf/util/session.h                |   1 +
 tools/perf/util/sort.h                   |  22 +-
 tools/perf/util/symbol.h                 |   2 -
 tools/perf/util/tool.h                   |   2 +
 35 files changed, 1455 insertions(+), 468 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
