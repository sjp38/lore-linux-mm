Date: Sun, 14 Nov 1999 15:22:18 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [patch] zoned-2.3.28-G5, zone-allocator, highmem, bootmem fixes
In-Reply-To: <199911141217.MAA00054@raistlin.arm.linux.org.uk>
Message-ID: <Pine.LNX.4.10.9911141441050.3555-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: cw@f00f.org, torvalds@transmeta.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, sct@redhat.com, hans-christoph.rohland@sap.com
List-ID: <linux-mm.kvack.org>

On Sun, 14 Nov 1999, Russell King wrote:

> Ingo Molnar writes:
> > no. The zone stuff is completely transparent, all GFP_* flags (should)  
> > work just as before. All interfaces were preserved. So shortly before 2.4
> > it is not acceptable to break established APIs. (neither is it necessery)
> 
> Except discontiguous memory systems, which I've now got a real bad
> headache for and am currently resorting to a fixed zone-size until the
> new stuff can be fixed.  Dunno if this is going to work yet, since the
> free watermarks are going to be just wrong.

interfacing the zone configuration to the lowlevel memory configuration is
not yet fully worked out.

do you see any conceptual problem with the current zoned allocator?

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
