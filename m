Date: Wed, 18 May 2005 23:46:57 -0700
From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] prevent NULL mmap in topdown model
Message-ID: <20050519064657.GH23013@shell0.pdx.osdl.net>
References: <Pine.LNX.4.61.0505181556190.3645@chimarrao.boston.redhat.com> <Pine.LNX.4.58.0505181535210.18337@ppc970.osdl.org> <Pine.LNX.4.61.0505182224250.29123@chimarrao.boston.redhat.com> <Pine.LNX.4.58.0505181946300.2322@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0505181946300.2322@ppc970.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Linus Torvalds (torvalds@osdl.org) wrote:
> However, it would be good to have even the trivial patch tested. 
> Especially since what it tries to fix is a total corner-case in the first 
> place..

I gave it a quick and simple test.  Worked as expected.  Last page got
mapped at 0x1000, leaving first page unmapped.  Of course, either with
MAP_FIXED or w/out MAP_FIXED but proper hint (like -1) you can still
map first page.  This isn't to say I was extra creative in testing.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
