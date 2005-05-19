Subject: Re: [PATCH] prevent NULL mmap in topdown model
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20050519064657.GH23013@shell0.pdx.osdl.net>
References: <Pine.LNX.4.61.0505181556190.3645@chimarrao.boston.redhat.com>
	 <Pine.LNX.4.58.0505181535210.18337@ppc970.osdl.org>
	 <Pine.LNX.4.61.0505182224250.29123@chimarrao.boston.redhat.com>
	 <Pine.LNX.4.58.0505181946300.2322@ppc970.osdl.org>
	 <20050519064657.GH23013@shell0.pdx.osdl.net>
Content-Type: text/plain
Date: Thu, 19 May 2005 10:15:10 +0200
Message-Id: <1116490511.6027.25.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-05-18 at 23:46 -0700, Chris Wright wrote:
> * Linus Torvalds (torvalds@osdl.org) wrote:
> > However, it would be good to have even the trivial patch tested. 
> > Especially since what it tries to fix is a total corner-case in the first 
> > place..
> 
> I gave it a quick and simple test.  Worked as expected.  Last page got
> mapped at 0x1000, leaving first page unmapped.  Of course, either with
> MAP_FIXED or w/out MAP_FIXED but proper hint (like -1) you can still
> map first page.  This isn't to say I was extra creative in testing.

sure. Making it *impossible* to mmap that page is bad. People should be
able to do that if they really want to, just doing it if they don't ask
for it is bad.

There are plenty of reasons people may want that page mmaped, one of
them being that the compiler can then do more speculative loads around
null pointer checks. Not saying it's a brilliant idea always, but making
such things impossible makes no sense.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
