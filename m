Date: Tue, 4 Jan 2005 14:11:18 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: page migration\
Message-ID: <20050104161118.GD7399@logos.cnet>
References: <20050103171344.GD14886@logos.cnet> <41D9AC2D.90409@sgi.com> <20050103183811.GE14886@logos.cnet> <20050105.004221.41649018.taka@valinux.co.jp> <41DAD393.1030009@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41DAD393.1030009@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 04, 2005 at 11:34:11AM -0600, Ray Bryant wrote:
> >>>
> >>>Absolutely.  I guess the only question is when to propose the merge with 
> >>>-mm
> >>>etc.  Is your defragmentation code in a good enough state to be proposed 
> >>>as
> >>>well, or should we wait a bit?
> >>
> >>No, we have to wait - its not ready yet.
> >>
> >>But it is really simple and small, as soon as the "asynchronous" memory 
> >>migration is working.
> >>
> >>
> >>>I think we need at least one user of the code before we can propose that 
> >>>the
> >>>memory migration code be merged, or do you think we the arguments are 
> >>>strong
> >>>enough we can proceed with users "pending"?
> >>
> >>IMO the arguments are strong enough that we can proceed with the current 
> >>state.
> >>I'm all for it.
> >>
> >>Andrew knows the importance and the users of the memory migration 
> >>infrastructure.
> >>
> >>Dave, Hirokazu, what are your thoughts on this
> >
> >
> >Andrew is interested in our approach.
> >With Ray's help, it will proceed faster and become stable soon:)
> >
> >
> >>Shall we CC Andrew?
> >>
> >
> >
> 
> If it is ok with everyone, I will email Andrew and see how he'd like to 
> proceed on this, whether he'd prefer we contribute a solid "user" of the 
> page migration code with a merged page migration patch, or if it would be 
> ok to
> submit the page migration code stand alone, given that there are multiple 
> users "pending".
> 
> Of course, I come to this effort late in the game, and if anyone else would
> prefer to do that instead, I will happily oblige them.

Please do that publically on linux-kernel - Dave has been doing most of the hardwork 
but I do not think he will mind if you start the discussion with Andrew.

Thanks Ray!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
