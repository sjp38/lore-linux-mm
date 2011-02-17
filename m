Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D69208D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 20:57:56 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] memcg: clarify use_hierarchy documentation
References: <201102170152.p1H1qKli008601@smtp-out.google.com>
Date: Wed, 16 Feb 2011 17:57:49 -0800
In-Reply-To: <201102170152.p1H1qKli008601@smtp-out.google.com> (Mail Delivery
	Subsystem's message of "Wed, 16 Feb 2011 17:52:20 -0800")
Message-ID: <xr93ei772zj6.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@xenotime.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

(cc correct linux-mm address)

The memcg code does not allow changing memory.use_hierarchy if the
parent cgroup has enabled use_hierarchy.  Update documentation to match
the code.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 Documentation/cgroups/memory.txt |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 7781857..b6ed61c 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -485,8 +485,9 @@ The feature can be disabled by
 
 # echo 0 > memory.use_hierarchy
 
-NOTE1: Enabling/disabling will fail if the cgroup already has other
-       cgroups created below it.
+NOTE1: Enabling/disabling will fail if either the cgroup already has other
+       cgroups created below it, or if the parent cgroup has use_hierarchy
+       enabled.
 
 NOTE2: When panic_on_oom is set to "2", the whole system will panic in
        case of an OOM event in any cgroup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
