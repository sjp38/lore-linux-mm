Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0DBBA6B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 10:25:49 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1285929315-2856-1-git-send-email-steve@digidescorp.com>
References: <1285929315-2856-1-git-send-email-steve@digidescorp.com>
Subject: Re: [PATCH][RESEND] nommu: add anonymous page memcg accounting
Date: Fri, 01 Oct 2010 15:24:55 +0100
Message-ID: <5206.1285943095@redhat.com>
Sender: owner-linux-mm@kvack.org
To: "Steven J. Magnani" <steve@digidescorp.com>
Cc: dhowells@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Steven J. Magnani <steve@digidescorp.com> wrote:

> Add the necessary calls to track VM anonymous page usage.

Do we really need to do memcg accounting in NOMMU mode?  Might it be better to
just apply the attached patch instead?

David
---
diff --git a/init/Kconfig b/init/Kconfig
index 2de5b1c..aecff10 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -555,7 +555,7 @@ config RESOURCE_COUNTERS
 
 config CGROUP_MEM_RES_CTLR
 	bool "Memory Resource Controller for Control Groups"
-	depends on CGROUPS && RESOURCE_COUNTERS
+	depends on CGROUPS && RESOURCE_COUNTERS && MMU
 	select MM_OWNER
 	help
 	  Provides a memory resource controller that manages both anonymous

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
