Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 924EF6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 03:49:25 -0500 (EST)
Date: Wed, 24 Nov 2010 17:48:36 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] mm: make ioremap_prot() take a pgprot.
Message-ID: <20101124084836.GH2212@linux-sh.org>
References: <20101102203102.GA12723@linux-sh.org> <20101108063403.GA12790@linux-sh.org> <1289225899.2147.1363.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289225899.2147.1363.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Chris Metcalf <cmetcalf@tilera.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 01:18:19AM +1100, Benjamin Herrenschmidt wrote:
> On Mon, 2010-11-08 at 15:34 +0900, Paul Mundt wrote:
> > On Wed, Nov 03, 2010 at 05:31:03AM +0900, Paul Mundt wrote:
> > > The current definition of ioremap_prot() takes an unsigned long for the
> > > page flags and then converts to/from a pgprot as necessary. This is
> > > unfortunately not sufficient for the SH-X2 TLB case which has a 64-bit
> > > pgprot and a 32-bit unsigned long.
> > > 
> > > An inspection of the tree shows that tile and cris also have their
> > > own equivalent routines that are using the pgprot_t but do not set
> > > HAVE_IOREMAP_PROT, both of which could trivially be adapted.
> > > 
> > > After cris/tile are updated there would also be enough critical mass to
> > > move the powerpc devm_ioremap_prot() in to the generic lib/devres.c.
> > > 
> > > Signed-off-by: Paul Mundt <lethal@linux-sh.org>
> > > 
> > Any takers?
> 
> Haven't had a chance to play with it yet, still travelling.
> 
Ping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
