Date: Fri, 8 Feb 2008 12:25:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm/slub.c - Use print_hex_dump
In-Reply-To: <1202501739.27394.96.camel@localhost>
Message-ID: <Pine.LNX.4.64.0802081224100.5358@schroedinger.engr.sgi.com>
References: <1202493808.27394.76.camel@localhost>
 <Pine.LNX.4.64.0802081006460.28568@schroedinger.engr.sgi.com>
 <1202495069.27394.85.camel@localhost>  <Pine.LNX.4.64.0802081031320.28862@schroedinger.engr.sgi.com>
 <1202501739.27394.96.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Randy Dunlap <randy.dunlap@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Argh. You need to cut that into small pieces so that it is easier to 
review. CCing Randy who was involved with prior art in this area.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
