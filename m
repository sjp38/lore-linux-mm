Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 62F216B006C
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 01:37:21 -0400 (EDT)
Received: by patj18 with SMTP id j18so34234022pat.2
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:21 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id rg4si300636pdb.144.2015.04.05.22.37.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Apr 2015 22:37:20 -0700 (PDT)
Received: by paboj16 with SMTP id oj16so34329274pab.0
        for <linux-mm@kvack.org>; Sun, 05 Apr 2015 22:37:20 -0700 (PDT)
From: Namhyung Kim <namhyung@kernel.org>
Subject: [PATCH 1/9] perf kmem: Respect -i option
Date: Mon,  6 Apr 2015 14:36:08 +0900
Message-Id: <1428298576-9785-2-git-send-email-namhyung@kernel.org>
In-Reply-To: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, Jiri Olsa <jolsa@kernel.org>

From: Jiri Olsa <jolsa@kernel.org>

Currently the perf kmem does not respect -i option.
Initializing the file.path properly after options
get parsed.

Signed-off-by: Jiri Olsa <jolsa@kernel.org>
Signed-off-by: Namhyung Kim <namhyung@kernel.org>
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
2.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
