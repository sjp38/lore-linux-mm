Date: Mon, 21 Nov 2005 14:29:10 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH 0/8] Critical Page Pool
Message-ID: <20051121132910.GA1971@elf.ucw.cz>
References: <437E2C69.4000708@us.ibm.com> <20051118195657.GI7991@shell0.pdx.osdl.net> <43815F64.4070502@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43815F64.4070502@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Chris Wright <chrisw@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

> > * Matthew Dobson (colpatch@us.ibm.com) wrote:
> > 
> >>/proc/sys/vm/critical_pages: write the number of pages you want to reserve
> >>for the critical pool into this file
> > 
> > 
> > How do you size this pool?
> 
> Trial and error.  If you want networking to survive with no memory other
> than the critical pool for 2 minutes, for example, you pick a random value,
> block all other allocations (I have a test patch to do this), and send a
> boatload of packets at the box.  If it OOMs, you need a bigger pool.
> Lather, rinse, repeat.

...and then you find out that your test was not "bad enough" or that
it needs more memory on different machines. It may be good enough hack
for your usage, but I do not think it belongs in mainline.
								Pavel
-- 
Thanks, Sharp!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
