Date: Wed, 18 May 2005 15:41:47 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] prevent NULL mmap in topdown model
In-Reply-To: <Pine.LNX.4.61.0505181714330.3645@chimarrao.boston.redhat.com>
Message-ID: <Pine.LNX.4.58.0505181540060.18337@ppc970.osdl.org>
References: <Pine.LNX.4.61.0505181556190.3645@chimarrao.boston.redhat.com>
 <1116448683.6572.43.camel@laptopd505.fenrus.org>
 <Pine.LNX.4.61.0505181714330.3645@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 18 May 2005, Rik van Riel wrote:
>
> On Wed, 18 May 2005, Arjan van de Ven wrote:
> > On Wed, 2005-05-18 at 15:57 -0400, Rik van Riel wrote:
> > > This (trivial) patch prevents the topdown allocator from allocating
> > > mmap areas all the way down to address zero.  It's not the prettiest
> > > patch, so suggestions for improvement are welcome ;)
> > 
> > it looks like you stop at brk() time.. isn't it better to just stop just 
> > above NULL instead?? Gives you more space and is less of an artificial 
> > barrier..
> 
> Firstly, there isn't much below brk() at all.

Guaranteed? What about executables that have fixed code addresses?

Sounds like a dubious approach, in other words.

If you want to, you could make the "how low do you go" thing be an
rlimit-like thing, but I really doubt "brk" makes much sense as the limit.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
