Date: Mon, 25 Sep 2000 15:12:50 -0600
From: yodaiken@fsmlabs.com
Subject: Re: the new VMt
Message-ID: <20000925151250.B20586@hq.fsmlabs.com>
References: <20000925143523.B19257@hq.fsmlabs.com> <Pine.LNX.3.96.1000925164556.9644A-100000@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.96.1000925164556.9644A-100000@kanga.kvack.org>; from Benjamin C.R. LaHaise on Mon, Sep 25, 2000 at 04:47:21PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: yodaiken@fsmlabs.com, "Stephen C. Tweedie" <sct@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:47:21PM -0400, Benjamin C.R. LaHaise wrote:
> On Mon, 25 Sep 2000 yodaiken@fsmlabs.com wrote:
> 
> > On Mon, Sep 25, 2000 at 09:23:48PM +0100, Alan Cox wrote:
> > > > my prediction is that if you show me an example of 
> > > > DoS vulnerability,  I can show you fix that does not require bean counting.
> > > > Am I wrong?
> > > 
> > > I think so. Page tables are a good example
> > 
> > I'm not too sure of what you have in mind, but if it is
> >      "process creates vast virtual space to generate many page table
> >       entries -- using mmap"
> > the answer is, virtual address space quotas and mmap should kill 
> > the process on low mem for page tables.
> 
> No.  Page tables are not freed after munmap (and for good reason).  The
> counting of page table "beans" is critical.

I've seen the assertion before, reasons would be interesting.


-- 
---------------------------------------------------------
Victor Yodaiken 
Finite State Machine Labs: The RTLinux Company.
 www.fsmlabs.com  www.rtlinux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
