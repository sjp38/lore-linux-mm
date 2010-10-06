Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E61416B0085
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 18:33:13 -0400 (EDT)
Date: Thu, 7 Oct 2010 00:33:08 +0200
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH] doc: clarify the behaviour of dirty_ratio/dirty_bytes
Message-ID: <20101006223307.GA1520@linux.develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

When dirty_ratio or dirty_bytes is written the other parameter is
disabled and set to 0 (in dirty_bytes_handler() /
dirty_ratio_handler()).

We do the same for dirty_background_ratio and dirty_background_bytes.

However, in the sysctl documentation, we say that the counterpart
becomes a function of the old value, that is not correct.

Clarify the documentation reporting the actual behaviour.

Reviewed-by: Greg Thelen <gthelen@google.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
---
 Documentation/sysctl/vm.txt |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index b606c2c..30289fa 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -80,8 +80,10 @@ dirty_background_bytes
 Contains the amount of dirty memory at which the pdflush background writeback
 daemon will start writeback.
 
-If dirty_background_bytes is written, dirty_background_ratio becomes a function
-of its value (dirty_background_bytes / the amount of dirtyable system memory).
+Note: dirty_background_bytes is the counterpart of dirty_background_ratio. Only
+one of them may be specified at a time. When one sysctl is written it is
+immediately taken into account to evaluate the dirty memory limits and the
+other appears as 0 when read.
 
 ==============================================================
 
@@ -97,8 +99,10 @@ dirty_bytes
 Contains the amount of dirty memory at which a process generating disk writes
 will itself start writeback.
 
-If dirty_bytes is written, dirty_ratio becomes a function of its value
-(dirty_bytes / the amount of dirtyable system memory).
+Note: dirty_bytes is the counterpart of dirty_ratio. Only one of them may be
+specified at a time. When one sysctl is written it is immediately taken into
+account to evaluate the dirty memory limits and the other appears as 0 when
+read.
 
 Note: the minimum value allowed for dirty_bytes is two pages (in bytes); any
 value lower than this limit will be ignored and the old configuration will be

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
