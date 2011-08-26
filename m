Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 885616B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 10:47:20 -0400 (EDT)
Date: Fri, 26 Aug 2011 10:46:53 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure
 changes
Message-ID: <20110826144653.GA889@dumpdata.com>
References: <20110823145755.GA23174@ca-server1.us.oracle.com>
 <20110825143312.a6fe93d5.kamezawa.hiroyu@jp.fujitsu.com>
 <8a95a804-7ba3-416e-9ba5-8da7b9cabba5@default20110826090214.2f7f2cdc.kamezawa.hiroyu@jp.fujitsu.com>
 <24f09c1f-3ff8-4677-a1f7-c3494ced04c1@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24f09c1f-3ff8-4677-a1f7-c3494ced04c1@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

On Fri, Aug 26, 2011 at 07:15:30AM -0700, Dan Magenheimer wrote:
> > From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> > Subject: Re: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure changes
> > 
> > > > From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> > > > Subject: Re: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure changes
> > >
> > > Hi Kamezawa-san --
> > >
> > > Domo arigato for the review and feedback!
> > >
> > > > Hmm....could you modify mm/swapfile.c and remove 'static' in the same patch ?
> > >
> > > I separated out this header patch because I thought it would
> > > make the key swap data structure changes more visible.  Are you
> > > saying that it is more confusing?
> > 
> > Yes. I know you add a new header file which is not included but..
> > 
> > At reviewing patch, I check whether all required changes are done.
> > In this case, you turned out the function to be externed but you
> > leave the function definition as 'static'. This unbalance confues me.
> > 
> > I always read patches from 1 to END. When I found an incomplete change
> > in patch 1, I remember it and need to find missng part from patch 2->End.
> > This makes my review confused a little.
> > 
> > In another case, when a patch adds a new file, I check Makefile change.
> > Considering dependency, the patch order should be
> > 
> > 	[patch 1] Documentaion/Config
> > 	[patch 2] Makefile + add new file.
> > 
> > But plesse note: This is my thought. Other guys may have other idea.
> 
> I think that is probably a good approach.  I will try to use it
> for future patches.  But since this frontswap patchset is already
> on V7, I hope it is OK if I continue to organize it for V8 the same
> as it has been, as it might be confusing to previous reviewers
> to change the organization now.

Nah, that is what part of the review process is - keep us on our toes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
