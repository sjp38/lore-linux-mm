Date: Wed, 28 Aug 2002 07:14:00 -0600 (MDT)
From: Thunder from the hill <thunder@lightweight.ods.org>
Subject: Re: [patch] SImple Topology API v0.3 (1/2)
In-Reply-To: <20020827143115.B39@toy.ucw.cz>
Message-ID: <Pine.LNX.4.44.0208280711390.3234-100000@hawkeye.luckynet.adm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Matthew Dobson <colpatch@us.ibm.com>, Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 27 Aug 2002, Pavel Machek wrote:
> > -   bool 'Multiquad NUMA system' CONFIG_MULTIQUAD
> > +   bool 'Multi-node NUMA system support' CONFIG_X86_NUMA
> 
> Why not simply CONFIG_NUMA?

Because NUMA is subordinate to X86, and another technology named NUMA 
might appear? Nano-uplinked micro-array... No Ugliness Munched Archive? 
Whatever...

			Thunder
-- 
--./../...-/. -.--/---/..-/.-./..././.-../..-. .---/..-/.../- .-
--/../-./..-/-/./--..-- ../.----./.-../.-.. --./../...-/. -.--/---/..-
.- -/---/--/---/.-./.-./---/.--/.-.-.-
--./.-/-.../.-./.././.-../.-.-.-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
