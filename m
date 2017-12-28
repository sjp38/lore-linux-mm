Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC6AC6B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 12:18:59 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a10so24049257pgq.3
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 09:18:59 -0800 (PST)
Message-ID: <1514481533.3040.6.camel@HansenPartnership.com>
Subject: Re: [RFC 0/8] Xarray object migration V1
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 28 Dec 2017 09:18:53 -0800
In-Reply-To: <alpine.DEB.2.20.1712280856260.30955@nuc-kabylake>
References: <20171227220636.361857279@linux.com>
	 <d54a8261-75f0-a9c8-d86d-e20b3b492ef9@infradead.org>
	 <alpine.DEB.2.20.1712280856260.30955@nuc-kabylake>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Randy Dunlap <rdunlap@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>, Benjamin LaHaise <bcrl@kvack.org>

On Thu, 2017-12-28 at 08:57 -0600, Christopher Lameter wrote:
> On Wed, 27 Dec 2017, Randy Dunlap wrote:
> 
> > 
> > > 
> > > To test apply this patchset on top of Matthew Wilcox Xarray code
> > > from Dec 11th (See infradead github).
> > 
> > linux-mm archive is missing patch 1/8 and so am I.
> > 
> > https://marc.info/?l=linux-mm
> 
> Duh. How can you troubleshoot that one?

Well you can ask for expert help. A The mm list also ate one of my bug
reports (although the followup made it). A This is the lost email:

From:	James Bottomley <James.Bottomley@HansenPartnership.com>
To:	Linux Memory Management List <linux-mm@kvack.org>
Subject:	Hang with v4.15-rc trying to swap back in
Date:	Wed, 27 Dec 2017 10:12:20 -0800
Message-Id:	<1514398340.3986.10.camel@HansenPartnership.com>

This is the accepting MTA line from postfix:

Dec 27 10:12:23 bedivere postfix/smtp[15670]: CFB7E8EE190: to=<linux-mm@kvack.org>, relay=aspmx.l.google.com[74.125.28.26]:25, delay=1.2, delays=0.09/0.03/0.6/0.42, dsn=2.0.0, status=sent (250 2.0.0 OK 1514398342 z21si24644492plo.126 - gsmtp)

The one that made it is:

Message-Id:	<1514407817.4169.4.camel@HansenPartnership.com>

I've cc'd Ben because I think the list is still on his systems.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
