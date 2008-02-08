Subject: Re: [PATCH] mm/slub.c - Use print_hex_dump
From: Joe Perches <joe@perches.com>
In-Reply-To: <Pine.LNX.4.64.0802081006460.28568@schroedinger.engr.sgi.com>
References: <1202493808.27394.76.camel@localhost>
	 <Pine.LNX.4.64.0802081006460.28568@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 08 Feb 2008 10:24:29 -0800
Message-Id: <1202495069.27394.85.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-02-08 at 10:07 -0800, Christoph Lameter wrote:
> On Fri, 8 Feb 2008, Joe Perches wrote:
> > Use the library function to dump memory
> Could you please compare the formatting of the output before and 
> after? Last time we tried this we had issues because it became a bit ugly.

The difference is the last line of the ascii is not aligned
if the length is non modulo 16.

I have sent a patch to print_hex_dump to always align.
http://lkml.org/lkml/2007/12/6/304


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
