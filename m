Message-ID: <3D767997.B6B76833@zip.com.au>
Date: Wed, 04 Sep 2002 14:22:31 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: nonblocking-vm.patch
References: <3D766999.A9C14E1E@zip.com.au> <Pine.LNX.4.44L.0209041755030.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 4 Sep 2002, Andrew Morton wrote:
> 
> > > get cleaned.  We can do this by simply refusing to
> > > scan that zone again for a number of jiffies, say
> > > 1/4 of a second.
> >
> > Well, it may be better to terminate that sleep earlier if IO
> > completes.
> 
> But only if enough IO completes. Otherwise we'll just end
> up doing too much scanning for no gain again.
> 

Well we want to _find_ the just-completed IO, yes?  Which implies
parking it onto the cold end of the inactive list at interrupt
time, or a separate list or something.

But let's look at the instrumentation and the profiles first.  I
expect it'll be OK.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
