Date: Mon, 3 Jan 2005 16:38:11 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: page migration\
Message-ID: <20050103183811.GE14886@logos.cnet>
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost> <41D99743.5000601@sgi.com> <20050103162406.GB14886@logos.cnet> <20050103171344.GD14886@logos.cnet> <41D9AC2D.90409@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41D9AC2D.90409@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 03, 2005 at 02:33:49PM -0600, Ray Bryant wrote:
> Marcelo Tosatti wrote:
> 
> >
> >
> >Memory migration makes sense for defragmentation too.
> >
> >I think we enough arguments for merging the migration code first, as you 
> >suggest.
> >
> >Its also easier to merge part-by-part than everything in one bunch.
> >
> >Yes?
> 
> Absolutely.  I guess the only question is when to propose the merge with -mm
> etc.  Is your defragmentation code in a good enough state to be proposed as
> well, or should we wait a bit?

No, we have to wait - its not ready yet.

But it is really simple and small, as soon as the "asynchronous" memory migration is working.

I'll try to work on it this weekend (I'm busy with other work unfortunately during the weekdays).

> I think we need at least one user of the code before we can propose that the
> memory migration code be merged, or do you think we the arguments are strong
> enough we can proceed with users "pending"?

IMO the arguments are strong enough that we can proceed with the current state.
I'm all for it.

Andrew knows the importance and the users of the memory migration infrastructure.

Dave, Hirokazu, what are your thoughts on this

Shall we CC Andrew?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
