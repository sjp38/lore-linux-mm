Date: Wed, 05 Jan 2005 00:42:21 +0900 (JST)
Message-Id: <20050105.004221.41649018.taka@valinux.co.jp>
Subject: Re: page migration\
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050103183811.GE14886@logos.cnet>
References: <20050103171344.GD14886@logos.cnet>
	<41D9AC2D.90409@sgi.com>
	<20050103183811.GE14886@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: raybry@sgi.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> > Marcelo Tosatti wrote:
> > 
> > >Memory migration makes sense for defragmentation too.
> > >
> > >I think we enough arguments for merging the migration code first, as you 
> > >suggest.
> > >
> > >Its also easier to merge part-by-part than everything in one bunch.
> > >
> > >Yes?
> > 
> > Absolutely.  I guess the only question is when to propose the merge with -mm
> > etc.  Is your defragmentation code in a good enough state to be proposed as
> > well, or should we wait a bit?
> 
> No, we have to wait - its not ready yet.
> 
> But it is really simple and small, as soon as the "asynchronous" memory migration is working.
>
> > I think we need at least one user of the code before we can propose that the
> > memory migration code be merged, or do you think we the arguments are strong
> > enough we can proceed with users "pending"?
> 
> IMO the arguments are strong enough that we can proceed with the current state.
> I'm all for it.
> 
> Andrew knows the importance and the users of the memory migration infrastructure.
> 
> Dave, Hirokazu, what are your thoughts on this

Andrew is interested in our approach.
With Ray's help, it will proceed faster and become stable soon:)

> Shall we CC Andrew?
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
