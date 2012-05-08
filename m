Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 64AEE6B0106
	for <linux-mm@kvack.org>; Tue,  8 May 2012 04:30:41 -0400 (EDT)
Message-ID: <1336465808.16236.13.camel@twins>
Subject: Re: [PATCH UPDATED 3/3] tracing: Provide trace events interface for
 uprobes
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 08 May 2012 10:30:08 +0200
In-Reply-To: <20120508041229.GD30652@gmail.com>
References: <20120409091133.8343.65289.sendpatchset@srdronam.in.ibm.com>
	 <20120409091154.8343.50489.sendpatchset@srdronam.in.ibm.com>
	 <20120411103043.GB29437@linux.vnet.ibm.com>
	 <20120508041229.GD30652@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On Tue, 2012-05-08 at 06:12 +0200, Ingo Molnar wrote:
> FYI, this warning started to trigger in -tip, with the latest=20
> uprobes patches:
>=20
> warning: (UPROBE_EVENT) selects UPROBES which has unmet direct dependenci=
es (UPROBE_EVENTS && PERF_EVENTS)

this looks to be the only UPROBE_EVENTS instance, is that a typo?

---
 arch/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 9e2fbb5..c160d92 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -78,7 +78,7 @@ config OPTPROBES
=20
 config UPROBES
 	bool "Transparent user-space probes (EXPERIMENTAL)"
-	depends on UPROBE_EVENTS && PERF_EVENTS
+	depends on UPROBE_EVENT && PERF_EVENTS
 	default n
 	help
 	  Uprobes is the user-space counterpart to kprobes: they

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
