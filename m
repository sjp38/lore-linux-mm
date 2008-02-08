Date: Fri, 8 Feb 2008 10:07:37 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm/slub.c - Use print_hex_dump
In-Reply-To: <1202493808.27394.76.camel@localhost>
Message-ID: <Pine.LNX.4.64.0802081006460.28568@schroedinger.engr.sgi.com>
References: <1202493808.27394.76.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Feb 2008, Joe Perches wrote:

> Use the library function to dump memory

Could you please compare the formatting of the output before and 
after? Last time we tried this we had issues because it became a bit ugly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
