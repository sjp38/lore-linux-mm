Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DEEC36B0107
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 17:35:48 -0400 (EDT)
Message-ID: <4E24A699.4070300@bx.jp.nec.com>
Date: Mon, 18 Jul 2011 17:33:13 -0400
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 1/5] perf tools: handle '-' and '*' in trace parsing
References: <4E24A61D.4060702@bx.jp.nec.com>
In-Reply-To: <4E24A61D.4060702@bx.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Keiichi KII <k-keiichi@bx.jp.nec.com>, Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Fr??d??ric Weisbecker <fweisbec@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "BA, Moussa" <Moussa.BA@numonyx.com>

From: Keiichi Kii <k-keiichi@bx.jp.nec.com>

add '-' and '*' to parsing in trace parsing.

Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
---

 tools/perf/util/trace-event-parse.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)


diff --git a/tools/perf/util/trace-event-parse.c b/tools/perf/util/trace-event-parse.c
index 0a7ed5b..447f7c0 100644
--- a/tools/perf/util/trace-event-parse.c
+++ b/tools/perf/util/trace-event-parse.c
@@ -2162,6 +2162,12 @@ static unsigned long long eval_num_arg(void *data, int size,
 		case '+':
 			val = left + right;
 			break;
+		case '*':
+			val = left * right;
+			break;
+		case '/':
+			val = left / right;
+			break;
 		default:
 			die("unknown op '%s'", arg->op.op);
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
