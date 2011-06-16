Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 548416B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 05:43:34 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110616052639.GI4952@linux.vnet.ibm.com>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
	 <1307660606.2497.1770.camel@laptop>
	 <20110616052639.GI4952@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 16 Jun 2011 11:42:24 +0200
Message-ID: <1308217344.15315.92.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 2011-06-16 at 10:56 +0530, Srikar Dronamraju wrote:

> If the comment is confusing I can delete it or reword it as suggested by
> Steven Rostedt which is  /* Have caller drop the creation ref */
>=20
> I would prefer to delete the comment.

Yeah, just drop the thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
