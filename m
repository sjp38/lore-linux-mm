Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 71D9C6B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 10:20:08 -0500 (EST)
Subject: Re: [RFC] [PATCH 2.6.37-rc5-tip 8/20]  8: uprobes: mmap and fork
 hooks.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110126150946.GK19725@linux.vnet.ibm.com>
References: 
	 <20101216095714.23751.52601.sendpatchset@localhost6.localdomain6>
	 <20101216095848.23751.73144.sendpatchset@localhost6.localdomain6>
	 <1295957741.28776.719.camel@laptop>
	 <20110126150946.GK19725@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 26 Jan 2011 16:20:43 +0100
Message-ID: <1296055243.28776.1209.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2011-01-26 at 20:39 +0530, Srikar Dronamraju wrote:
>=20
> B. use the current match_inode but change the search_within_subtree
> logic. search_within_subtree() would first find the leftmode node
> within the subtree that still has the same inode. Thereafter it will use
> rb_next().
>=20
> Do you have any other ideas?=20

Look for the right inode but with offset 0, that should get you the
leftmost matching inode, or the entry left of that (depending on how you
build the tree), after that you should be able to iterate all probes of
that inode by using rb_next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
