Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 9909B6B0093
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 07:28:28 -0400 (EDT)
Received: by wibhq4 with SMTP id hq4so305133wib.8
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 04:28:26 -0700 (PDT)
Date: Sat, 8 Sep 2012 13:28:14 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [GIT PULL 00/13] perf/core improvements and fixes
Message-ID: <20120908112814.GA21851@gmail.com>
References: <1347070032-4161-1-git-send-email-acme@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347070032-4161-1-git-send-email-acme@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: linux-kernel@vger.kernel.org, Adrian Hunter <adrian.hunter@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Corey Ashford <cjashfor@linux.vnet.ibm.com>, David Ahern <dsahern@gmail.com>, Frederic Weisbecker <fweisbec@gmail.com>, Irina Tirdea <irina.tirdea@intel.com>, Jiri Olsa <jolsa@redhat.com>, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Namhyung Kim <namhyung@kernel.org>, Namhyung Kim <namhyung.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@redhat.com>


* Arnaldo Carvalho de Melo <acme@infradead.org> wrote:

> Hi Ingo,
> 
> 	Please consider pulling,
> 
> - Arnaldo
> 
> The following changes since commit 479d875835a49e849683743ec50c30b6a429696b:
> 
>   Merge tag 'perf-core-for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/core (2012-09-07 07:36:59 +0200)
> 
> are available in the git repository at:
> 
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux tags/perf-core-for-mingo
> 
> for you to fetch changes up to b155a09015135cf59ada8d48109ccbd9891c1b42:
> 
>   perf tools: Fix build for another rbtree.c change (2012-09-07 22:21:59 -0300)
> 
> ----------------------------------------------------------------
> perf/core improvements and fixes
> 
>  . Fix build for another rbtree.c change, from Adrian Hunter.
> 
>  . Fixes for perf to build on Android, from Irina Tirdea.
> 
>  . Make 'perf diff' command work with evsel hists, from Jiri Olsa.
> 
>  . Use the only field_sep var that is set up: symbol_conf.field_sep,
>    fix from Jiri Olsa.
> 
>  . .gitignore compiled python binaries, from Namhyung Kim.
> 
>  . Get rid of die() in more libtraceevent places, from Namhyung Kim.
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> ----------------------------------------------------------------
> Adrian Hunter (1):
>       perf tools: Fix build for another rbtree.c change
> 
> Irina Tirdea (6):
>       perf tools: include basename for non-glibc systems
>       perf tools: fix missing winsize definition
>       perf tools: include missing pthread.h header
>       perf tools: replace mkostemp with mkstemp
>       tools lib traceevent: replace mempcpy with memcpy
>       perf tools: add NO_BACKTRACE for application self-debugging
> 
> Jiri Olsa (2):
>       perf diff: Make diff command work with evsel hists
>       perf tools: Replace sort's standalone field_sep with symbol_conf.field_sep
> 
> Namhyung Kim (4):
>       perf tools: Ignore compiled python binaries
>       tools lib traceevent: Get rid of die() from pretty_print()
>       tools lib traceevent: Get rid of die() from pevent_register_event_handler
>       tools lib traceevent: Get rid of die() from pevent_register_print_function
> 
>  tools/lib/traceevent/event-parse.c     |   86 +++++++++++++++++++++--------
>  tools/lib/traceevent/event-parse.h     |    3 +-
>  tools/perf/.gitignore                  |    2 +
>  tools/perf/Documentation/perf-diff.txt |    3 ++
>  tools/perf/Makefile                    |    8 +++
>  tools/perf/builtin-diff.c              |   93 +++++++++++++++++++++-----------
>  tools/perf/config/feature-tests.mak    |   14 +++++
>  tools/perf/perf.c                      |    1 +
>  tools/perf/util/annotate.h             |    1 +
>  tools/perf/util/dso-test-data.c        |    2 +-
>  tools/perf/util/evsel.h                |    7 +++
>  tools/perf/util/help.c                 |    1 +
>  tools/perf/util/include/linux/rbtree.h |    1 +
>  tools/perf/util/session.h              |    4 +-
>  tools/perf/util/sort.c                 |    6 +--
>  tools/perf/util/sort.h                 |    1 -
>  tools/perf/util/symbol.h               |    3 ++
>  tools/perf/util/top.h                  |    1 +
>  tools/perf/util/util.c                 |    6 +++
>  19 files changed, 180 insertions(+), 63 deletions(-)

Pulled, thanks a lot Arnaldo!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
