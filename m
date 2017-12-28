Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 28 Dec 2017 15:33:52 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [RFC 0/8] Xarray object migration V1
Message-ID: <20171228203352.GP24310@kvack.org>
References: <20171227220636.361857279@linux.com> <d54a8261-75f0-a9c8-d86d-e20b3b492ef9@infradead.org> <alpine.DEB.2.20.1712280856260.30955@nuc-kabylake> <1514481533.3040.6.camel@HansenPartnership.com> <20171228173351.GK24310@kvack.org> <1514482820.3040.13.camel@HansenPartnership.com> <20171228191748.GO24310@kvack.org> <1514491258.3040.28.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1514491258.3040.28.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Christopher Lameter <cl@linux.com>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>

On Thu, Dec 28, 2017 at 12:00:58PM -0800, James Bottomley wrote:
...
> > The list is not hosted on Google - Google's anti-spam service is only
> > used for ingress filtering.
> 
> OK, but that is the problem: you're relying on google infrastructure
> for a service it does incredibly poorly.

I did say that I am open to changing how spam filtering is done.

> > Spamassassin is not a "Good Enough" option these days given the
> > volume and nature of spam that comes into kvack.org.  If you can
> > point me at a better anti-spam solution that actually works (and is
> > not RBL based), I'd be happy to try it since the Google service is
> > absolutely awful with pretty much no way to get a human to fix
> > obviously broken things.
> 
> Well, to be honest, I find spamassassin to be incredibly useful (it's
> what I use), especially being rules and points based instead of
> absolute (meaning I can use the RBL but not rely on it).  It hasn't
> given me a false positive on anything for over a year and its false
> negative rate is about 2% with my current configuration.

False negative rate last time I used spam assassin was way more than
10-15%, and it mostly failed to filter out the phishing scams which tend
to be the bigger problem of late.  That isn't so much of a mailing list
concern, but it is a significant issue for user accounts.

> However, I think the best solution is to use vger ... it already has an
> efficient ingress filter and it doesn't rely on google, so it doesn't
> suffer the arbitrary mail loss problem of google.

This is the first time anyone has complained to me about messages being
filtered in a number of years, and I have added whitelists for people over
the years that had problems ending up on various blacklists.  I don't have
time these days to actively scan mailing lists for issues, so reporting
them on-list without directly Cc'ing me will not get my attention.  I'll
look into options over the next few days and see if there are any better
solutions available now than the last time I looked at the spam problem.
Please give me at least a little a bit of time to look into possible fixes
before going nuclear.

		-ben

> James
> 
> 

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
