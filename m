Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 706979000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 15:37:03 -0400 (EDT)
Subject: Re: [PATCH 3/8] kstaled: page_referenced_kstaled() and supporting
 infrastructure.
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 20 Sep 2011 21:36:39 +0200
In-Reply-To: <1316230753-8693-4-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	 <1316230753-8693-4-git-send-email-walken@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1316547399.13664.65.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>, rostedt <rostedt@goodmis.org>

On Fri, 2011-09-16 at 20:39 -0700, Michel Lespinasse wrote:
> +PAGEFLAG(Young, young)

We should probably do something like the below, I couldn't figure out a
way to make it do multiple functions from one macro though so I picked
the simple PageFoo test..=20

I even added an Emacs variant, although I didn't test it..

---
 scripts/tags.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/scripts/tags.sh b/scripts/tags.sh
index 75c5d24f1..b07797a 100755
--- a/scripts/tags.sh
+++ b/scripts/tags.sh
@@ -132,7 +132,8 @@ exuberant()
 	--regex-asm=3D'/^ENTRY\(([^)]*)\).*/\1/'                  \
 	--regex-c=3D'/^SYSCALL_DEFINE[[:digit:]]?\(([^,)]*).*/sys_\1/' \
 	--regex-c++=3D'/^TRACE_EVENT\(([^,)]*).*/trace_\1/'		\
-	--regex-c++=3D'/^DEFINE_EVENT\([^,)]*, *([^,)]*).*/trace_\1/'
+	--regex-c++=3D'/^DEFINE_EVENT\([^,)]*, *([^,)]*).*/trace_\1/'	\
+	--regex-c++=3D'/^PAGEFLAG\(([^,)]*).*/Page\1/'
=20
 	all_kconfigs | xargs $1 -a                              \
 	--langdef=3Dkconfig --language-force=3Dkconfig              \
@@ -154,7 +155,8 @@ emacs()
 	--regex=3D'/^ENTRY(\([^)]*\)).*/\1/'                      \
 	--regex=3D'/^SYSCALL_DEFINE[0-9]?(\([^,)]*\).*/sys_\1/'   \
 	--regex=3D'/^TRACE_EVENT(\([^,)]*\).*/trace_\1/'		\
-	--regex=3D'/^DEFINE_EVENT([^,)]*, *\([^,)]*\).*/trace_\1/'
+	--regex=3D'/^DEFINE_EVENT([^,)]*, *\([^,)]*\).*/trace_\1/'\
+	--regex=3D'/^PAGEFLAG(\([^,)]*\).*/Page\1/'
=20
 	all_kconfigs | xargs $1 -a                              \
 	--regex=3D'/^[ \t]*\(\(menu\)*config\)[ \t]+\([a-zA-Z0-9_]+\)/\3/'

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
