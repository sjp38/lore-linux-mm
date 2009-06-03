Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 22F036B00C0
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:24:52 -0400 (EDT)
Date: Wed, 3 Jun 2009 08:24:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090603062445.GA27563@wotan.suse.de>
References: <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601183225.GS1065@one.firstfloor.org> <20090602120042.GB1392@wotan.suse.de> <20090602124757.GG1065@one.firstfloor.org> <20090602150952.GB17448@wotan.suse.de> <20090602171915.GS1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602171915.GS1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 07:19:15PM +0200, Andi Kleen wrote:
> On Tue, Jun 02, 2009 at 05:09:52PM +0200, Nick Piggin wrote:
> > On Tue, Jun 02, 2009 at 02:47:57PM +0200, Andi Kleen wrote:
> > > On Tue, Jun 02, 2009 at 02:00:42PM +0200, Nick Piggin wrote:
> > 
> > [snip: reusing truncate.c code]
> > 
> > > > With all that writing you could have just done it. It's really
> > > 
> > > I would have done it if it made sense to me, but so far it hasn't.
> > > 
> > > The problem with your suggestion is that you do the big picture,
> > > but seem to skip over a lot of details. But details matter.
> > 
> > BTW. just to answer this point. The reason maybe for this
> > is because the default response to my concerns seems to
> > have been "you're wrong". Not "i don't understand, can you
> > detail", and not "i don't agree because ...".
> 
> Sorry, I didn't want to imply you're wrong. I apologize if
> it came over this way. I understand you understand this code
> very well. I realize the one above came out 
> a bit flamey, but it wasn't really intended like this.

Ah it's OK :) Actually that was too far, most of the time
actually you gave constructive responses. Just one or two
sticking points but probably I was getting carried away
as well. Nothing personal of course!

 
> I'll take a look at your suggestion this evening and see
> how it comes out.

Cool.

 
> > Anyway don't worry. I get that a lot. I do really want to
> > help get this merged.
> 
> I wanted to thank you for your great reviewing work, even if I didn't
> agree with everything :) But I think the disagreement were quite
> small and only relatively unimportant things.

Yes, I see nothing fundamentally wrong with the design...

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
