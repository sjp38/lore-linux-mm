Date: Wed, 28 Aug 2002 14:02:15 -0600 (MDT)
From: Thunder from the hill <thunder@lightweight.ods.org>
Subject: Re: [patch] SImple Topology API v0.3 (1/2)
In-Reply-To: <20020828192917.GC10487@atrey.karlin.mff.cuni.cz>
Message-ID: <Pine.LNX.4.44.0208281400580.3234-100000@hawkeye.luckynet.adm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Thunder from the hill <thunder@lightweight.ods.org>, Matthew Dobson <colpatch@us.ibm.com>, Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 28 Aug 2002, Pavel Machek wrote:
> > Because NUMA is subordinate to X86, and another technology named NUMA 
> > might appear? Nano-uplinked micro-array... No Ugliness Munched Archive? 
> > Whatever...
> 
> NUMA means non-uniform memory access. At least IBM, AMD and SGI do
> NUMA; and I guess anyone with 100+ nodes *has* numa machine. (BUt as
> andrea already explained, CONFIG_NUMA is already taken for generic
> NUMA support.)

I'm aware of that. You didn't get my point, though. I was just suggesting 
that there might be other things called NUMA, so CONFIG_X86_NUMA may be 
just right.

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
