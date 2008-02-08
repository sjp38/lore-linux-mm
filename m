Subject: Re: [PATCH] mm/slub.c - Use print_hex_dump
From: Joe Perches <joe@perches.com>
In-Reply-To: <Pine.LNX.4.64.0802081224100.5358@schroedinger.engr.sgi.com>
References: <1202493808.27394.76.camel@localhost>
	 <Pine.LNX.4.64.0802081006460.28568@schroedinger.engr.sgi.com>
	 <1202495069.27394.85.camel@localhost>
	 <Pine.LNX.4.64.0802081031320.28862@schroedinger.engr.sgi.com>
	 <1202501739.27394.96.camel@localhost>
	 <Pine.LNX.4.64.0802081224100.5358@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 08 Feb 2008 12:33:18 -0800
Message-Id: <1202502798.27394.100.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Randy Dunlap <randy.dunlap@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-02-08 at 12:25 -0800, Christoph Lameter wrote:
> Argh. You need to cut that into small pieces so that it is easier to 
> review. CCing Randy who was involved with prior art in this area.

lib/hexdump is the major change.
mm/slub is a removal/conversion.
the rest are trivial.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
