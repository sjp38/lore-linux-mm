Date: Tue, 4 Jan 2005 17:15:24 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
In-Reply-To: <20050104164720.3863d312.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0501041713560.2222@schroedinger.engr.sgi.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
 <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
 <Pine.GSO.4.61.0501011123550.27452@waterleaf.sonytel.be>
 <Pine.LNX.4.58.0501041510430.1536@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041629490.4111@ppc970.osdl.org> <20050104164720.3863d312.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Jan 2005, Andrew Morton wrote:

> > Ok, let's start merging this slowly
>
> One week hence, please.  Things like the no-bitmaps-for-the-buddy-allocator
> have been well tested and should go in first.

The first two patches are basically cleanup type stuff and will not affect
the page allocator in a significant way. On the other hand they touch many
files and are thus difficult to maintain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
