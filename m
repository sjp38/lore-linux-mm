Date: Mon, 21 May 2007 00:24:22 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Message-ID: <20070520222422.GT2012@bingen.suse.de>
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr> <20070520205500.GJ22452@vanheusden.com> <200705202314.57758.ak@suse.de> <20070520212036.GL22452@vanheusden.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070520212036.GL22452@vanheusden.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Folkert van Heusden <folkert@vanheusden.com>
Cc: Andi Kleen <ak@suse.de>, Jan Engelhardt <jengelh@linux01.gwdg.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, righiandr@users.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 20, 2007 at 11:20:36PM +0200, Folkert van Heusden wrote:
> > > +	switch(sig) {
> > > +	case SIGQUIT: 
> > > +	case SIGILL: 
> > > +	case SIGTRAP:
> > > +	case SIGABRT: 
> > > +	case SIGBUS: 
> > > +	case SIGFPE:
> > > +	case SIGSEGV: 
> > > +	case SIGXCPU: 
> > > +	case SIGXFSZ:
> > > +	case SIGSYS: 
> > > +	case SIGSTKFLT:
> > 
> > Unconditional? That's definitely a very bad idea. If anything only unhandled
> > signals should be printed this way because some programs use them internally. 
> 
> Use these signals internally? Afaik these are fatal, stopping the
> process. So using them internally would be a little tricky.

All of them are catchable.

> 
> > But I think your list is far too long anyways.
> 
> So, which ones would you like to have removed then?

SIGFPE at least and the accounting signals are dubious too. SIGQUIT can
be also relatively common.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
