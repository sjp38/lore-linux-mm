Subject: Re: [patch 10/17] LTTng instrumentation - swap
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080716144008.GG24546@Krystal>
References: <20080715222604.331269462@polymtl.ca>
	 <20080715222748.214360024@polymtl.ca> <1216197576.5232.27.camel@twins>
	 <20080716144008.GG24546@Krystal>
Content-Type: text/plain
Date: Wed, 16 Jul 2008 16:47:34 +0200
Message-Id: <1216219654.5232.55.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Masami Hiramatsu <mhiramat@redhat.com>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, "Frank Ch. Eigler" <fche@redhat.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-07-16 at 10:40 -0400, Mathieu Desnoyers wrote:
> * Peter Zijlstra (peterz@infradead.org) wrote:
> > On Tue, 2008-07-15 at 18:26 -0400, Mathieu Desnoyers wrote:

> > > @@ -1796,6 +1799,7 @@ get_swap_info_struct(unsigned type)
> > >  {
> > >  	return &swap_info[type];
> > >  }
> > > +EXPORT_SYMBOL_GPL(get_swap_info_struct);
> > 
> > I'm not too happy with this export.
> > 
> 
> Would it make more sense to turn get_swap_info_struct into a static
> inline in swap.h ?

Seeing a consumer of it would go a long way towards discussing it ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
