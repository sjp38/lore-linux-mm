Date: Mon, 25 Sep 2000 16:47:21 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: the new VMt
In-Reply-To: <20000925143523.B19257@hq.fsmlabs.com>
Message-ID: <Pine.LNX.3.96.1000925164556.9644A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000 yodaiken@fsmlabs.com wrote:

> On Mon, Sep 25, 2000 at 09:23:48PM +0100, Alan Cox wrote:
> > > my prediction is that if you show me an example of 
> > > DoS vulnerability,  I can show you fix that does not require bean counting.
> > > Am I wrong?
> > 
> > I think so. Page tables are a good example
> 
> I'm not too sure of what you have in mind, but if it is
>      "process creates vast virtual space to generate many page table
>       entries -- using mmap"
> the answer is, virtual address space quotas and mmap should kill 
> the process on low mem for page tables.

No.  Page tables are not freed after munmap (and for good reason).  The
counting of page table "beans" is critical.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
