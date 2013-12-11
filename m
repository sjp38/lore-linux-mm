Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id D07FA6B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 19:26:18 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f64so4537345yha.17
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:26:18 -0800 (PST)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id t39si10404672yhp.50.2013.12.10.16.26.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 16:26:17 -0800 (PST)
Received: by mail-yh0-f47.google.com with SMTP id 29so4492065yhl.6
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:26:17 -0800 (PST)
Date: Tue, 10 Dec 2013 16:26:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] checkpatch: add warning of future __GFP_NOFAIL use
In-Reply-To: <alpine.DEB.2.02.1312101618530.22701@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1312101624330.22701@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312091355360.11026@chino.kir.corp.google.com> <20131209152202.df3d4051d7dc61ada7c420a9@linux-foundation.org> <alpine.DEB.2.02.1312101504120.22701@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1312101618530.22701@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@canonical.com>, Joe Perches <joe@perches.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

gfp.h and page_alloc.c already specify that __GFP_NOFAIL is deprecated and 
no new users should be added.

Add a warning to checkpatch to catch this.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 scripts/checkpatch.pl | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 9c98100..6667689 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -4114,6 +4114,12 @@ sub process {
 			     "$1 uses number as first arg, sizeof is generally wrong\n" . $herecurr);
 		}
 
+# check for GFP_NOWAIT use
+		if ($line =~ /\b__GFP_NOFAIL\b/) {
+			WARN("__GFP_NOFAIL",
+			     "Use of __GFP_NOFAIL is deprecated, no new users should be added\n" . $herecurr);
+		}
+
 # check for multiple semicolons
 		if ($line =~ /;\s*;\s*$/) {
 			if (WARN("ONE_SEMICOLON",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
