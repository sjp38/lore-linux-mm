Subject: Re: [Lse-tech] Re: [patch] SImple Topology API v0.3 (1/2)
From: "Timothy D. Witham" <wookie@osdl.org>
In-Reply-To: <20020828192917.GC10487@atrey.karlin.mff.cuni.cz>
References: <20020827143115.B39@toy.ucw.cz>
	<Pine.LNX.4.44.0208280711390.3234-100000@hawkeye.luckynet.adm>
	<20020828192917.GC10487@atrey.karlin.mff.cuni.cz>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 28 Aug 2002 15:31:55 -0700
Message-Id: <1030573915.3178.128.camel@wookie-t23.pdx.osdl.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Thunder from the hill <thunder@lightweight.ods.org>, Matthew Dobson <colpatch@us.ibm.com>, Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

How about the old Marketing name CONFIG_CCNUMA?



Tim

On Wed, 2002-08-28 at 12:29, Pavel Machek wrote:
> Hi!
> 
> > > > -   bool 'Multiquad NUMA system' CONFIG_MULTIQUAD
> > > > +   bool 'Multi-node NUMA system support' CONFIG_X86_NUMA
> > > 
> > > Why not simply CONFIG_NUMA?
> > 
> > Because NUMA is subordinate to X86, and another technology named NUMA 
> > might appear? Nano-uplinked micro-array... No Ugliness Munched Archive? 
> > Whatever...
> 
> NUMA means non-uniform memory access. At least IBM, AMD and SGI do
> NUMA; and I guess anyone with 100+ nodes *has* numa machine. (BUt as
> andrea already explained, CONFIG_NUMA is already taken for generic
> NUMA support.)
> 
> 							Pavel
> 
> -- 
> Casualities in World Trade Center: ~3k dead inside the building,
> cryptography in U.S.A. and free speech in Czech Republic.
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by: Jabber - The world's fastest growing 
> real-time communications platform! Don't just IM. Build it in! 
> http://www.jabber.com/osdn/xim
> _______________________________________________
> Lse-tech mailing list
> Lse-tech@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lse-tech
-- 
Timothy D. Witham - Lab Director - wookie@osdlab.org
Open Source Development Lab Inc - A non-profit corporation
15275 SW Koll Parkway - Suite H - Beaverton OR, 97006
(503)-626-2455 x11 (office)    (503)-702-2871     (cell)
(503)-626-2436     (fax)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
