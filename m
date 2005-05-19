Date: Thu, 19 May 2005 01:23:45 -0700
From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] prevent NULL mmap in topdown model
Message-ID: <20050519082345.GI23013@shell0.pdx.osdl.net>
References: <Pine.LNX.4.61.0505181556190.3645@chimarrao.boston.redhat.com> <Pine.LNX.4.58.0505181535210.18337@ppc970.osdl.org> <Pine.LNX.4.61.0505182224250.29123@chimarrao.boston.redhat.com> <Pine.LNX.4.58.0505181946300.2322@ppc970.osdl.org> <20050519064657.GH23013@shell0.pdx.osdl.net> <1116490511.6027.25.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1116490511.6027.25.camel@laptopd505.fenrus.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Chris Wright <chrisw@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Arjan van de Ven (arjan@infradead.org) wrote:
> On Wed, 2005-05-18 at 23:46 -0700, Chris Wright wrote:
> > I gave it a quick and simple test.  Worked as expected.  Last page got
> > mapped at 0x1000, leaving first page unmapped.  Of course, either with
> > MAP_FIXED or w/out MAP_FIXED but proper hint (like -1) you can still
> > map first page.  This isn't to say I was extra creative in testing.
> 
> sure. Making it *impossible* to mmap that page is bad. People should be
> able to do that if they really want to, just doing it if they don't ask
> for it is bad.

Heh, that was actually my intended point ;-)  At any rate, you made it
clearer, thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
