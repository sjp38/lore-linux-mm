Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D09779000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 09:00:30 -0400 (EDT)
Subject: Re: [PATCH v5 3.1.0-rc4-tip 18/26]   uprobes: slot allocation.
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 27 Sep 2011 14:59:50 +0200
In-Reply-To: <20110927123225.GC15435@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
	 <20110920120335.25326.50673.sendpatchset@srdronam.in.ibm.com>
	 <1317124177.15383.46.camel@twins>
	 <20110927123225.GC15435@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317128390.15383.58.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Stephen Smalley <sds@tycho.nsa.gov>, LKML <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>

On Tue, 2011-09-27 at 18:02 +0530, Srikar Dronamraju wrote:
> I used to keep the changelog after the marker after Christoph Hellwig
> had suggested that https://lkml.org/lkml/2010/7/20/5
> However "stg export" removes lines after the --- marker.=20

That's no excuse for writing shitty changelogs. Version logs contain the
incremental changes in each version, but the changelog should be a full
and proper description of the patch, irrespective of how many iterations
and changes it has undergone.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
