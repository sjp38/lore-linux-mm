Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing
	usable for other purposes
From: Nigel Cunningham <ncunningham@cyclades.com>
Reply-To: ncunningham@cyclades.com
In-Reply-To: <20050626023053.GA2871@atrey.karlin.mff.cuni.cz>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net>
	 <20050625025122.GC22393@atrey.karlin.mff.cuni.cz>
	 <Pine.LNX.4.62.0506242311220.7971@graphe.net>
	 <20050626023053.GA2871@atrey.karlin.mff.cuni.cz>
Content-Type: text/plain
Message-Id: <1119783254.8083.5.camel@localhost>
Mime-Version: 1.0
Date: Sun, 26 Jun 2005 20:54:14 +1000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Christoph Lameter <christoph@lameter.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, raybry@engr.sgi.com, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi!

On Sun, 2005-06-26 at 12:30, Pavel Machek wrote:
> > Index: linux-2.6.12/arch/i386/kernel/signal.c
> > ===================================================================
> > --- linux-2.6.12.orig/arch/i386/kernel/signal.c	2005-06-25 05:01:26.000000000 +0000
> > +++ linux-2.6.12/arch/i386/kernel/signal.c	2005-06-25 05:01:28.000000000 +0000
> > @@ -608,10 +608,8 @@ int fastcall do_signal(struct pt_regs *r
> >  	if (!user_mode(regs))
> >  		return 1;
> >  
> > -	if (current->flags & PF_FREEZE) {
> > -		refrigerator(0);
> > +	if (try_to_freeze)
> >  		goto no_signal;
> > -	}
> >  
> 
> This is not good. Missing ().

Thanks!

I was just going to begin a search to find out why, after applying it,
everything stopped dead in the water :>

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
