Date: Sun, 14 Nov 1999 22:32:39 +1300
From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [patch] zoned-2.3.28-G5, zone-allocator, highmem, bootmem fixes
Message-ID: <19991114223239.A1332@caffeine.ix.net.nz>
References: <19991114110625.A155@caffeine.ix.net.nz> <Pine.LNX.4.10.9911141110480.1278-100000@chiara.csoma.elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.9911141110480.1278-100000@chiara.csoma.elte.hu>; from Ingo Molnar on Sun, Nov 14, 1999 at 11:16:40AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu, "Stephen C. Tweedie" <sct@redhat.com>, Christoph Rohland <hans-christoph.rohland@sap.com>
List-ID: <linux-mm.kvack.org>

> the solution is to:
> 
>  -#include <asm/pgtable.h>
>  +#include <asm/pgalloc.h>

> we do not want to put #ifdef CONFIG_X86-type of stuff into the main
> kernel.

pgalloc.h only exists fof x86 -- so this won't work

> > > - fixed boot task's swapper_pg_dir clearing
> > 
> > what else needs to be done to alloc the buffer cache to use the low
> > 16MB? 
> 
> fallback from 'highmem => normalmem => dmamem' should work already.

stupid question perhaps, but how can I verify this...

> will have a look - i think we are simply out of balance somewhere,

ok, perhaps this is it -- should drivers and the swap code need to
know about the zone stuff and explicity do things differently?



-cw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
