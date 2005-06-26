Date: Sun, 26 Jun 2005 05:09:25 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable for other purposes
Message-ID: <20050626030925.GA4156@atrey.karlin.mff.cuni.cz>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net> <20050625025122.GC22393@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506242311220.7971@graphe.net> <20050626023053.GA2871@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506251954470.26198@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0506251954470.26198@graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, raybry@engr.sgi.com, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

Hi!

> > > 4. Remove the argument that is no longer necessary from two function
> > > calls.
> > 
> > Can you just keep the argument? Rename it to int unused or whatever,
> > but if you do it, it stays backwards-compatible (and smaller patch,
> > too).
> 
> Why do you want to specify a parameter that is never used? It was quite confusing to me 
> and I would think that such a parameter will also be confusing to others.

Well, yes, it is slightly confusing, but such patch can go in through
different maintainers, and different pieces can come in at different
times.

If you delete an argument, it is "flag day", and I'll (or you) will
have to coordinate it with akpm as one "atomic" patch.... As lots of
different subsystems (and => lots of maintainers) are involved, I'd
prefer to keep the argument for now.
								Pavel
-- 
Boycott Kodak -- for their patent abuse against Java.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
