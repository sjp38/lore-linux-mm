Subject: Re: mapped page in prep_new_page()..
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.58.0402270709152.2563@ppc970.osdl.org>
References: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org>
	 <20040226225809.669d275a.akpm@osdl.org>
	 <Pine.LNX.4.58.0402262305000.2563@ppc970.osdl.org>
	 <1077878329.22925.321.camel@gaston>
	 <Pine.LNX.4.58.0402270709152.2563@ppc970.osdl.org>
Content-Type: text/plain
Message-Id: <1077919599.22954.6.camel@gaston>
Mime-Version: 1.0
Date: Sat, 28 Feb 2004 09:06:40 +1100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, hch@infradead.org, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2004-02-28 at 02:32, Linus Torvalds wrote:
> On Fri, 27 Feb 2004, Benjamin Herrenschmidt wrote:
> >
> > > Heh. I've had this G5 thing for a couple of weeks, I'm not very good at 
> > > reading the oops dump either ;)
> > 
> > DAR is the access address for a 300 trap
> 
> Yeah, that makes complete sense now. "DAR" and "300 trap". I should have 
> seen it immediately.

Heh, well, i didn't say it was good, I told you the info for next time :)

But I agree that is far from explicit. Anton or I will come up with
a patch making it nicer.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
