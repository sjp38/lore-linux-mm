Date: Sat, 25 Jun 2005 19:55:50 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [RFC] Fix SMP brokenness for PF_FREEZE and make freezing usable
 for other purposes
In-Reply-To: <20050626023053.GA2871@atrey.karlin.mff.cuni.cz>
Message-ID: <Pine.LNX.4.62.0506251954470.26198@graphe.net>
References: <Pine.LNX.4.62.0506241316370.30503@graphe.net>
 <20050625025122.GC22393@atrey.karlin.mff.cuni.cz> <Pine.LNX.4.62.0506242311220.7971@graphe.net>
 <20050626023053.GA2871@atrey.karlin.mff.cuni.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, raybry@engr.sgi.com, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Sun, 26 Jun 2005, Pavel Machek wrote:

> > 4. Remove the argument that is no longer necessary from two function
> > calls.
> 
> Can you just keep the argument? Rename it to int unused or whatever,
> but if you do it, it stays backwards-compatible (and smaller patch,
> too).

Why do you want to specify a parameter that is never used? It was quite confusing to me 
and I would think that such a parameter will also be confusing to others.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
