Date: Mon, 21 May 2007 00:21:20 +0200 (MEST)
Message-Id: <200705202221.l4KMLKvI002716@harpo.it.uu.se>
From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de, folkert@vanheusden.com
Cc: dada1@cosmosbay.com, jengelh@linux01.gwdg.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, righiandr@users.sourceforge.net, shemminger@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 May 2007 23:20:36 +0200, Folkert van Heusden wrote:
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

Tricky for Joe Programmer, perhaps.

I've been personally involved with writing SIGFPE-handling code
in a major telco application framework, for several different
CPU architectures and operating systems.

SIGSEGV is used by some garbage collectors, some JITs, and I believe
also some software distributed shared memory implementations.

I've heard of at least one Lisp implementation that used SIGBUS
instead of dynamic type checks in some operations (e.g. to catch
CAR of a non-CONS).

Handled signals should not be logged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
