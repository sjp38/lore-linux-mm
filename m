Message-ID: <48D93665.8030200@linux-foundation.org>
Date: Tue, 23 Sep 2008 13:33:09 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: Unified tracing buffer
References: <33307c790809191433w246c0283l55a57c196664ce77@mail.gmail.com> <1221869279.8359.31.camel@lappy.programming.kicks-ass.net> <20080922140740.GB5279@in.ibm.com> <1222094724.16700.11.camel@lappy.programming.kicks-ass.net> <1222147545.6875.135.camel@charm-linux> <1222162270.16700.57.camel@lappy.programming.kicks-ass.net> <20080923181313.GA4947@Krystal>
In-Reply-To: <20080923181313.GA4947@Krystal>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <compudj@krystal.dyndns.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Tom Zanussi <zanussi@comcast.net>, prasad@linux.vnet.ibm.com, Martin Bligh <mbligh@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, od@novell.com, "Frank Ch. Eigler" <fche@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de, David Wilder <dwilder@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mathieu Desnoyers wrote:
> 
> I think we should instead try to figure out what is currently missing in
> the kernel vmap mechanism (probably the ability to vmap from large 4MB
> pages after boot), and fix _that_ instead (if possible), which would not
> only benefit to tracing, but also to module support.

With some custom code one can vmap 2MB pages on x86. See the VMEMMAP support
in the x86 arch. The code in mm/sparse-vmemmap.c could be abstracted for a
general 2MB mapping API to reduce TLB pressure for the buffers. If there are
concerns about fragmentation then one could fallback to 4kb TLBs. See the
virtualizable compound page patchset which does something similar.

> I added Christoph Lameter to the CC list, he always comes with clever
> ideas. :)

Oh mostly we are just recycling the old ideas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
