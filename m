Date: Fri, 16 Nov 2001 07:17:51 -0800 (PST)
Message-Id: <20011116.071751.12999342.davem@redhat.com>
Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20011116150454.J25491@parcelfarce.linux.theplanet.co.uk>
References: <200111160730.AAA18774@puffin.external.hp.com>
	<20011116.065243.134136673.davem@redhat.com>
	<20011116150454.J25491@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: willy@debian.org
Cc: grundler@puffin.external.hp.com, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

   On Fri, Nov 16, 2001 at 06:52:43AM -0800, David S. Miller wrote:
   > 
   > No, you must have page+offset because in the future the
   > "address" field of scatterlist is going to disappear
   > and _ONLY_ page+offset will be used.
   
   but _WHY_ in 2.4?  this is ridiculous for something which is alleged to
   be a stable kernel.
   
You have to add two members to a silly structure which nobody
uses right now, that is so horrible.  What affect on stability
does that change have?

This makes merging of Jen's Axboe's block highmem code back into
2.4.x painless.  That is why.

Franks a lot,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
