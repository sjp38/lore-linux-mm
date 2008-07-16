Received: from toip6.srvr.bell.ca ([209.226.175.125])
          by tomts10-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080716161715.TMWN1721.tomts10-srv.bellnexxia.net@toip6.srvr.bell.ca>
          for <linux-mm@kvack.org>; Wed, 16 Jul 2008 12:17:15 -0400
Date: Wed, 16 Jul 2008 12:17:14 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 10/17] LTTng instrumentation - swap
Message-ID: <20080716161714.GA31889@Krystal>
References: <1216219654.5232.55.camel@twins> <20080716150046.GI24546@Krystal> <20080717004734.1579.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <20080717004734.1579.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Masami Hiramatsu <mhiramat@redhat.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, "Frank Ch. Eigler" <fche@redhat.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro (kosaki.motohiro@jp.fujitsu.com) wrote:
> Hi
> 
> > > > Would it make more sense to turn get_swap_info_struct into a static
> > > > inline in swap.h ?
> > > 
> > > Seeing a consumer of it would go a long way towards discussing it ;-)
> > 
> > The LTTng probe which connects to this tracepoint looks like :
> 
> I have no objection to this exporting.
> 
> However, This is LTTng requirement.
> but tracepoint is tracer independent mechanism.
> then, split out is better IMHO.
> 

Good point. I'll move it to my following lttng-specific patches.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
