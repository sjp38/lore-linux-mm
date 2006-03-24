Date: Fri, 24 Mar 2006 13:19:39 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH][5/8] proc: export mlocked pages info through "/proc/meminfo:
 Wired"
In-Reply-To: <442420A2.80807@yahoo.com.au>
Message-ID: <Pine.LNX.4.63.0603241319130.30426@cuia.boston.redhat.com>
References: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>  <441FEFC7.5030109@yahoo.com.au>
 <bc56f2f0603210733vc3ce132p@mail.gmail.com> <442098B6.5000607@yahoo.com.au>
 <Pine.LNX.4.63.0603241133550.30426@cuia.boston.redhat.com> <442420A2.80807@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Stone Wang <pwstone@gmail.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Mar 2006, Nick Piggin wrote:
> Rik van Riel wrote:
> > On Wed, 22 Mar 2006, Nick Piggin wrote:
> > 
> > > Why would you want to ever do something like that though? I don't think
> > > you should use this name "just in case", unless you have some really good
> > > potential usage in mind.
> > 
> > ramfs
> 
> Why would ramfs want its pages in this wired list? (I'm not so
> familiar with it but I can't think of a reason).

Because ramfs pages cannot be paged out, which makes them locked
into memory the same way mlocked pages are.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
