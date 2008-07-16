Date: Thu, 17 Jul 2008 00:50:33 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 10/17] LTTng instrumentation - swap
In-Reply-To: <20080716150046.GI24546@Krystal>
References: <1216219654.5232.55.camel@twins> <20080716150046.GI24546@Krystal>
Message-Id: <20080717004734.1579.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Masami Hiramatsu <mhiramat@redhat.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, "Frank Ch. Eigler" <fche@redhat.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Hi

> > > Would it make more sense to turn get_swap_info_struct into a static
> > > inline in swap.h ?
> > 
> > Seeing a consumer of it would go a long way towards discussing it ;-)
> 
> The LTTng probe which connects to this tracepoint looks like :

I have no objection to this exporting.

However, This is LTTng requirement.
but tracepoint is tracer independent mechanism.
then, split out is better IMHO.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
