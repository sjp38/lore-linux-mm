Date: Thu, 17 Jun 2004 12:50:45 +0200
From: Miquel van Smoorenburg <miquels@cistron.nl>
Subject: Re: Keeping mmap'ed files in core regression in 2.6.7-rc
Message-ID: <20040617105045.GA30742@traveler.cistron.net>
References: <20040608142918.GA7311@traveler.cistron.net> <40CAA904.8080305@yahoo.com.au> <20040614140642.GE13422@traveler.cistron.net> <40CE66EE.8090903@yahoo.com.au> <20040615143159.GQ19271@traveler.cistron.net> <40CFBB75.1010702@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <40CFBB75.1010702@yahoo.com.au> (from nickpiggin@yahoo.com.au on Wed, Jun 16, 2004 at 05:16:05 +0200)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Miquel van Smoorenburg <miquels@cistron.nl>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2004.06.16 05:16, Nick Piggin wrote:
> Miquel van Smoorenburg wrote:
> > According to Nick Piggin:
> > 
> >>Miquel van Smoorenburg wrote:
> >>
> >>>
> >>>The patch below indeed fixes this problem. Now most of the mmap'ed files
> >>>are actually kept in memory and RSS is around 600 MB again:
> >>
> >>OK good. Cc'ing Andrew.
> > 
> > 
> > I've built a small test app that creates the same I/O pattern and ran it
> > on 2.6.6, 2.6.7-rc3 and 2.6.7-rc3+patch and running that confirms it,
> > though not as dramatically as the real-life application.
> > 
> 
> Can you send the test app over?
> Andrew, do you have any ideas about how to fix this so far?

I'll have to come back on this later - I'm about to go on
vacation, and there's some other stuff that needs to be
taken care of first.

Mike.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
