Date: Sun, 14 Nov 1999 11:43:25 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [patch] zoned-2.3.28-G5, zone-allocator, highmem, bootmem fixes
In-Reply-To: <19991114223239.A1332@caffeine.ix.net.nz>
Message-ID: <Pine.LNX.4.10.9911141139400.1618-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wedgwood <cw@f00f.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu, "Stephen C. Tweedie" <sct@redhat.com>, Christoph Rohland <hans-christoph.rohland@sap.com>
List-ID: <linux-mm.kvack.org>

On Sun, 14 Nov 1999, Chris Wedgwood wrote:

> >  -#include <asm/pgtable.h>
> >  +#include <asm/pgalloc.h>
> 
> > we do not want to put #ifdef CONFIG_X86-type of stuff into the main
> > kernel.
> 
> pgalloc.h only exists fof x86 -- so this won't work

well, other architectures will have to be fixed, this is a work in
progress patch.

> > fallback from 'highmem => normalmem => dmamem' should work already.
> 
> stupid question perhaps, but how can I verify this...

printk?

> > will have a look - i think we are simply out of balance somewhere,
> 
> ok, perhaps this is it -- should drivers and the swap code need to
> know about the zone stuff and explicity do things differently?

no. The zone stuff is completely transparent, all GFP_* flags (should)  
work just as before. All interfaces were preserved. So shortly before 2.4
it is not acceptable to break established APIs. (neither is it necessery)

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
