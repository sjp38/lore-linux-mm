Date: Sat, 21 Sep 2002 16:28:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: overcommit stuff
Message-ID: <20020921232824.GB25605@holomorphy.com>
References: <3D8D0046.EF119E03@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D8D0046.EF119E03@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Sep 21, 2002 at 04:27:02PM -0700, Andrew Morton wrote:
> Alan,
> running 10,000 tiobench threads I'm showing 23 gigs of
> `Commited_AS'.  Is this right?  Those pages are shared,
> and if they're not PROT_WRITEable then there's no way in
> which they can become unshared?   Seems to be excessively
> pessimistic?
> Or is 2.5 not up to date?
> Thanks.

Hmm, that sounds different from what I see, I usually see between
75GB and 250GB of Committed_AS. OTOH that does seem "over the top",
esp. since the ZONE_NORMAL OOM's usually hit with between 18GB and
30GB of ZONE_HIGHMEM totally untouched.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
