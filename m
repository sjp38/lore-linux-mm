Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 855D86B0253
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 12:40:24 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id z3so23732726pln.6
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 09:40:24 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id p3si27024755pld.717.2017.12.28.09.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 09:40:23 -0800 (PST)
Message-ID: <1514482820.3040.13.camel@HansenPartnership.com>
Subject: Re: [RFC 0/8] Xarray object migration V1
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 28 Dec 2017 09:40:20 -0800
In-Reply-To: <20171228173351.GK24310@kvack.org>
References: <20171227220636.361857279@linux.com>
	 <d54a8261-75f0-a9c8-d86d-e20b3b492ef9@infradead.org>
	 <alpine.DEB.2.20.1712280856260.30955@nuc-kabylake>
	 <1514481533.3040.6.camel@HansenPartnership.com>
	 <20171228173351.GK24310@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <ben@communityfibre.ca>
Cc: Christopher Lameter <cl@linux.com>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Thu, 2017-12-28 at 12:33 -0500, Benjamin LaHaise wrote:
> On Thu, Dec 28, 2017 at 09:18:53AM -0800, James Bottomley wrote:
> ...
> > 
> > Well you can ask for expert help. A The mm list also ate one of my
> > bug reports (although the followup made it). A This is the lost
> > email:
> > 
> > From:	James Bottomley <James.Bottomley@HansenPartnership.com
> > >
> > To:	Linux Memory Management List <linux-mm@kvack.org>
> > Subject:	Hang with v4.15-rc trying to swap back in
> > Date:	Wed, 27 Dec 2017 10:12:20 -0800
> > Message-Id:	<1514398340.3986.10.camel@HansenPartnership.com>
> ...
> > 
> > I've cc'd Ben because I think the list is still on his systems.
> ...
> 
> Looks like Google's anti-spam service filtered it, so my system never
> even saw it.A A Not much I can do when that happens other than try to
> manually track it down.

I honestly don't think it's safe to host a public email list on google:
their "spam" filter is eccentric to say the least and is far too
willing to generate false positives for reasons no-one seems to be able
to fix. A What about moving the list to reliable infrastructure, like
vger?

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
