Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 81D086004B1
	for <linux-mm@kvack.org>; Tue, 18 May 2010 09:55:25 -0400 (EDT)
Subject: Re: [PATCH] cache last free vmap_area to avoid restarting beginning
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <1274100132.3158.27.camel@localhost.localdomain>
References: <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>
	 <1271350270.2013.29.camel@barrios-desktop>
	 <1271427056.7196.163.camel@localhost.localdomain>
	 <1271603649.2100.122.camel@barrios-desktop>
	 <1271681929.7196.175.camel@localhost.localdomain>
	 <h2g28c262361004190712v131bf7a3q2a82fd1168faeefe@mail.gmail.com>
	 <1272548602.7196.371.camel@localhost.localdomain>
	 <1272821394.2100.224.camel@barrios-desktop>
	 <1273063728.7196.385.camel@localhost.localdomain>
	 <20100505161632.GB5378@laptop>
	 <1274100132.3158.27.camel@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 18 May 2010 14:44:27 +0100
Message-Id: <1274190267.3158.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 2010-05-17 at 13:42 +0100, Steven Whitehouse wrote:
> Hi,
> 
> On Thu, 2010-05-06 at 02:16 +1000, Nick Piggin wrote:
> > On Wed, May 05, 2010 at 01:48:48PM +0100, Steven Whitehouse wrote:
> > > Hi,
> > > 
> > > On Mon, 2010-05-03 at 02:29 +0900, Minchan Kim wrote:
> > > > Hi, Steven. 
> > > > 
> > > > Sorry for lazy response.
> > > > I wanted to submit the patch which implement Nick's request whole.
> > > > And unfortunately, I am so busy now. 
> > > > But if it's urgent, I want to submit this one firstly and 
> > > > at next version, maybe I will submit remained TODO things 
> > > > after middle of May.
> > > > 
> > > > I think this patch can't make regression other usages.
> > > > Nick. What do you think about?
> > > > 
> > > I guess the question is whether the remaining items are essential for
> > > correct functioning of this patch, or whether they are "it would be nice
> > > if" items. I suspect that they are the latter (I'm not a VM expert, but
> > > from the brief descriptions it looks like that to me) in which case I'd
> > > suggest send the currently existing patch first and the following up
> > > with the remaining changes later.
> > > 
> > > We have got a nice speed up with your current patch and so far as I'm
> > > aware not introduced any new bugs or regressions with it.
> > > 
> > > Nick, does that sound ok?
> > 
> > Just got around to looking at it again. I definitely agree we need to
> > fix the regression, however I'm concerned about introducing other
> > possible problems while doing that.
> > 
> > The following patch should (modulo bugs, but it's somewhat tested) give
> > no difference in the allocation patterns, so won't introduce virtual
> > memory layout changes.
> > 
> > Any chance you could test it?
> > 
> 
> Apologies for the delay. I tried the patch on my test box and it worked
> perfectly ok. When the original test was tried which triggered the
> investigation in the first place, it failed to boot. Since that box is
> remote and with limited remote console access, all I've been able to
> find out is "it didn't work" which isn't very helpful.
> 
> I'm currently trying to figure out how we can work out whats wrong. It
> isn't at all certain that it is an issue with this patch - it could be
> almost anything :(
> 
> Steve.
> 
> 

Further tests show that exactly the same kernel, without that single
patch works ok, and but that with the patch we get the crash on boot. We
are trying to arrange for better console access to the test box (which
is remote) and will report back if we manage that and capture any
output,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
