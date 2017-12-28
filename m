Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6156B0033
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 15:01:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r8so5070806pgq.1
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 12:01:02 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id g1si27287003pfk.52.2017.12.28.12.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 12:01:00 -0800 (PST)
Message-ID: <1514491258.3040.28.camel@HansenPartnership.com>
Subject: Re: [RFC 0/8] Xarray object migration V1
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 28 Dec 2017 12:00:58 -0800
In-Reply-To: <20171228191748.GO24310@kvack.org>
References: <20171227220636.361857279@linux.com>
	 <d54a8261-75f0-a9c8-d86d-e20b3b492ef9@infradead.org>
	 <alpine.DEB.2.20.1712280856260.30955@nuc-kabylake>
	 <1514481533.3040.6.camel@HansenPartnership.com>
	 <20171228173351.GK24310@kvack.org>
	 <1514482820.3040.13.camel@HansenPartnership.com>
	 <20171228191748.GO24310@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <ben@communityfibre.ca>
Cc: Christopher Lameter <cl@linux.com>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Thu, 2017-12-28 at 14:17 -0500, Benjamin LaHaise wrote:
> On Thu, Dec 28, 2017 at 09:40:20AM -0800, James Bottomley wrote:
> > 
> > On Thu, 2017-12-28 at 12:33 -0500, Benjamin LaHaise wrote:
> > > 
> > > On Thu, Dec 28, 2017 at 09:18:53AM -0800, James Bottomley wrote:
> > > ...
> > > > 
> > > > 
> > > > Well you can ask for expert help. A The mm list also ate one of
> > > > my bug reports (although the followup made it). A This is the
> > > > lost email:
> > > > 
> > > > From:	James Bottomley <James.Bottomley@HansenPartnership
> > > > .com
> > > > > 
> > > > > 
> > > > To:	Linux Memory Management List <linux-mm@kvack.org>
> > > > Subject:	Hang with v4.15-rc trying to swap back in
> > > > Date:	Wed, 27 Dec 2017 10:12:20 -0800
> > > > Message-Id:	<1514398340.3986.10.camel@HansenPartnership.
> > > > com>
> > > ...
> > > > 
> > > > 
> > > > I've cc'd Ben because I think the list is still on his systems.
> > > ...
> > > 
> > > Looks like Google's anti-spam service filtered it, so my system
> > > never even saw it.A A Not much I can do when that happens other
> > > than try to manually track it down.
> > 
> > I honestly don't think it's safe to host a public email list on
> > google: their "spam" filter is eccentric to say the least and is
> > far too willing to generate false positives for reasons no-one
> > seems to be able to fix. A What about moving the list to reliable
> > infrastructure, like vger?
> 
> The list is not hosted on Google - Google's anti-spam service is only
> used for ingress filtering.

OK, but that is the problem: you're relying on google infrastructure
for a service it does incredibly poorly.

> Spamassassin is not a "Good Enough" option these days given the
> volume and nature of spam that comes into kvack.org.A A If you can
> point me at a better anti-spam solution that actually works (and is
> not RBL based), I'd be happy to try it since the Google service is
> absolutely awful with pretty much no way to get a human to fix
> obviously broken things.

Well, to be honest, I find spamassassin to be incredibly useful (it's
what I use), especially being rules and points based instead of
absolute (meaning I can use the RBL but not rely on it). A It hasn't
given me a false positive on anything for over a year and its false
negative rate is about 2% with my current configuration.

However, I think the best solution is to use vger ... it already has an
efficient ingress filter and it doesn't rely on google, so it doesn't
suffer the arbitrary mail loss problem of google.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
