Date: Wed, 28 Aug 2002 21:29:17 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [patch] SImple Topology API v0.3 (1/2)
Message-ID: <20020828192917.GC10487@atrey.karlin.mff.cuni.cz>
References: <20020827143115.B39@toy.ucw.cz> <Pine.LNX.4.44.0208280711390.3234-100000@hawkeye.luckynet.adm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0208280711390.3234-100000@hawkeye.luckynet.adm>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thunder from the hill <thunder@lightweight.ods.org>
Cc: Matthew Dobson <colpatch@us.ibm.com>, Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi!

> > > -   bool 'Multiquad NUMA system' CONFIG_MULTIQUAD
> > > +   bool 'Multi-node NUMA system support' CONFIG_X86_NUMA
> > 
> > Why not simply CONFIG_NUMA?
> 
> Because NUMA is subordinate to X86, and another technology named NUMA 
> might appear? Nano-uplinked micro-array... No Ugliness Munched Archive? 
> Whatever...

NUMA means non-uniform memory access. At least IBM, AMD and SGI do
NUMA; and I guess anyone with 100+ nodes *has* numa machine. (BUt as
andrea already explained, CONFIG_NUMA is already taken for generic
NUMA support.)

							Pavel

-- 
Casualities in World Trade Center: ~3k dead inside the building,
cryptography in U.S.A. and free speech in Czech Republic.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
