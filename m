Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id B9C696B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 09:43:52 -0500 (EST)
Date: Fri, 18 Jan 2013 14:43:51 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] slub: Check for page NULL before doing the node_match
 check
In-Reply-To: <1358464245.23211.62.camel@gandalf.local.home>
Message-ID: <0000013c4e1da430-0d8efce2-01b6-4862-b7b1-2ccd6503fc17-000000@email.amazonses.com>
References: <1358446258.23211.32.camel@gandalf.local.home> <1358447864.23211.34.camel@gandalf.local.home> <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com> <1358458996.23211.46.camel@gandalf.local.home>
 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com> <1358462763.23211.57.camel@gandalf.local.home> <1358464245.23211.62.camel@gandalf.local.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>

On Thu, 17 Jan 2013, Steven Rostedt wrote:

> Because there's also nothing to keep page related to object either, we
> may just need to do:

Adding the NULL check is satisfactory I think. The TID check guarantees
that nothing happened in between and the call the __slab_alloc can do the
same as the fastpath if it mistakenly goes to the slowpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
