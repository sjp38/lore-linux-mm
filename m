Date: Fri, 23 Dec 2005 09:27:33 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Zoned counters V1 [14/14]: Remove wbs
In-Reply-To: <2cd57c900512230357o17c8d0f0l@mail.gmail.com>
Message-ID: <Pine.LNX.4.62.0512230926400.13126@schroedinger.engr.sgi.com>
References: <20051220220151.30326.98563.sendpatchset@schroedinger.engr.sgi.com>
  <20051220220303.30326.16531.sendpatchset@schroedinger.engr.sgi.com>
 <2cd57c900512230357o17c8d0f0l@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Coywolf Qi Hunt <coywolf@gmail.com>
Cc: linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Dec 2005, Coywolf Qi Hunt wrote:

> >  static void
> > -get_dirty_limits(struct writeback_state *wbs, long *pbackground, long *pdirty,
> > -               struct address_space *mapping)
> > +get_dirty_limits(long *pbackground, long *pdirty, struct address_space *mapping)
> 
> Maybe get rid of the odd Hungarian naming too.

s/pbackground/background s/pdirty/dirty ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
