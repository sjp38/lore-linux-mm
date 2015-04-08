Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1506B006E
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 10:24:09 -0400 (EDT)
Received: by iebmp1 with SMTP id mp1so75190220ieb.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 07:24:09 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id m3si9737958ige.4.2015.04.08.07.24.08
        for <linux-mm@kvack.org>;
        Wed, 08 Apr 2015 07:24:08 -0700 (PDT)
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 04/19] perf kmem: Respect -i option
Date: Wed,  8 Apr 2015 11:23:24 -0300
Message-Id: <1428503019-23820-5-git-send-email-acme@kernel.org>
In-Reply-To: <1428503019-23820-1-git-send-email-acme@kernel.org>
References: <1428503019-23820-1-git-send-email-acme@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, Jiri Olsa <jolsa@kernel.org>, David Ahern <dsahern@gmail.com>, Jiri Olsa <jolsa@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Namhyung Kim <namhyung@kernel.org>, Arnaldo Carvalho de Melo <acme@redhat.com>

From: Jiri Olsa <jolsa@kernel.org>

Currently the perf kmem does not respect -i option.

Initializing the file.path properly after options get parsed.

Signed-off-by: Jiri Olsa <jolsa@kernel.org>
Cc: David Ahern <dsahern@gmail.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1428298576-9785-2-git-send-email-namhyung@kernel.org
Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/builtin-kmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index ac303ef9f2f0..4ebf65c79434 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -663,7 +663,6 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 {
 	const char * const default_sort_order = "frag,hit,bytes";
 	struct perf_data_file file = {
-		.path = input_name,
 		.mode = PERF_DATA_MODE_READ,
 	};
 	const struct option kmem_options[] = {
@@ -701,6 +700,8 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
 		return __cmd_record(argc, argv);
 	}
 
+	file.path = input_name;
+
 	session = perf_session__new(&file, false, &perf_kmem);
 	if (session == NULL)
 		return -1;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
