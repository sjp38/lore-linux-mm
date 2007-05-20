Date: Sun, 20 May 2007 23:20:36 +0200
From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Message-ID: <20070520212036.GL22452@vanheusden.com>
References: <464C9D82.60105@redhat.com> <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr> <20070520205500.GJ22452@vanheusden.com> <200705202314.57758.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200705202314.57758.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, righiandr@users.sourceforge.net, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > +	switch(sig) {
> > +	case SIGQUIT: 
> > +	case SIGILL: 
> > +	case SIGTRAP:
> > +	case SIGABRT: 
> > +	case SIGBUS: 
> > +	case SIGFPE:
> > +	case SIGSEGV: 
> > +	case SIGXCPU: 
> > +	case SIGXFSZ:
> > +	case SIGSYS: 
> > +	case SIGSTKFLT:
> 
> Unconditional? That's definitely a very bad idea. If anything only unhandled
> signals should be printed this way because some programs use them internally. 

Use these signals internally? Afaik these are fatal, stopping the
process. So using them internally would be a little tricky.

> But I think your list is far too long anyways.

So, which ones would you like to have removed then?


Folkert van Heusden

-- 
To MultiTail einai ena polymorfiko ergaleio gia ta logfiles kai tin
eksodo twn entolwn. Prosferei: filtrarisma, xrwmatismo, sygxwneysi,
diaforetikes provoles. http://www.vanheusden.com/multitail/
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
