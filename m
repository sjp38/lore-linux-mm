Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id F02C76B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 17:12:47 -0400 (EDT)
From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH 01/17] percpu: mark const init data with __initconst instead of __initdata
Date: Thu, 29 Mar 2012 23:12:18 +0200
Message-Id: <1333055554-31300-1-git-send-email-u.kleine-koenig@pengutronix.de>
In-Reply-To: <20120329211131.GA31250@pengutronix.de>
References: <20120329211131.GA31250@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel@pengutronix.de, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org

As long as there is no other non-const variable marked __initdata in the
same compilation unit it doesn't hurt. If there were one however
compilation would fail with

	error: $variablename causes a section type conflict

because a section containing const variables is marked read only and so
cannot contain non-const variables.

Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
---
 mm/percpu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index f47af91..5e812f5 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1370,7 +1370,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 #ifdef CONFIG_SMP
 
-const char *pcpu_fc_names[PCPU_FC_NR] __initdata = {
+const char *pcpu_fc_names[PCPU_FC_NR] __initconst = {
 	[PCPU_FC_AUTO]	= "auto",
 	[PCPU_FC_EMBED]	= "embed",
 	[PCPU_FC_PAGE]	= "page",
-- 
1.7.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
