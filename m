Date: Wed, 28 Jun 2000 18:46:46 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: kmap_kiobuf()
Message-ID: <20000628184646.C2392@redhat.com>
References: <200006281554.KAA19007@jen.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200006281554.KAA19007@jen.americas.sgi.com>; from lord@sgi.com on Wed, Jun 28, 2000 at 10:54:40AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lord@sgi.com
Cc: David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, sct@redhat.com, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 28, 2000 at 10:54:40AM -0500, lord@sgi.com wrote:

> I always knew it would go down like a ton of bricks, because of the TLB
> flushing costs. As soon as you have a multi-cpu box this operation gets
> expensive, the code could be changed to do lazy tlb flushes on unmapping
> the pages, but you still have the cost every time you set a mapping up.

That's exactly what kmap() is for --- it does all the lazy tlb
flushing for you.  Of course, the kmap area can get fragmented so it's
not a magic solution if you really need contiguous virtual mappings.

However, kmap caches the virtual mappings for you automatically, so it
may well be fast enough for you that you can avoid the whole
contiguous map thing and just kmap pages as you need them.  Is that
impossible for your code?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
