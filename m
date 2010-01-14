Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 83CDA6B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 05:22:17 -0500 (EST)
Date: Thu, 14 Jan 2010 12:22:11 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v5] add MAP_UNLOCKED mmap flag
Message-ID: <20100114102211.GM18808@redhat.com>
References: <20100114162327.673E.A69D9226@jp.fujitsu.com>
 <20100114080117.GL18808@redhat.com>
 <20100114170247.6747.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114170247.6747.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 14, 2010 at 05:17:36PM +0900, KOSAKI Motohiro wrote:
> > > Hmm..
> > > Your answer didn't match I wanted.
> > Then I don't get what you want.
> 
> I want to know the benefit of the patch for patch reviewing.
> 
> 
> > > few additional questions.
> > > 
> > > - Why don't you change your application? It seems natural way than kernel change.
> > There is no way to change my application and achieve what I've described
> > in a multithreaded app.
> 
> Then, we don't recommend to use mlockall(). I don't hope to hear your conclusion,
> it is not objectivization. I hope to hear why you reached such conclusion.
So what do you recommend? Don't just wave hand on me saying "These
aren't the droids you're looking for". I explained you what I need to
achieve you seems to be trying to convince me I don't really need it
without proposing any alternatives. This is not constructive discussion.

> 
> 
> > > - Why do you want your virtual machine have mlockall? AFAIK, current majority
> > >   virtual machine doesn't.
> > It is absolutely irrelevant for that patch, but just because you ask I
> > want to measure the cost of swapping out of a guest memory.
> 
> No. if you stop to use mlockall, the issue is vanished.
>
And emulator parts will be swapped out too which is not what I want.
 
> 
> > > - If this feature added, average distro user can get any benefit?
> > > 
> > ?! Is this some kind of new measure? There are plenty of much more
> > invasive features that don't bring benefits to an average distro user.
> > This feature can bring benefit to embedded/RT developers.
> 
> I mean who get benifit?
Someone who wants to mlock all application memory, but wants to be able
to mmap big file for reading and understand that access to that file can
cause major fault. 

> 
> 
> > > I mean, many application developrs want to add their specific feature
> > > into kernel. but if we allow it unlimitedly, major syscall become
> > > the trushbox of pretty toy feature soon.
> > > 
> > And if application developer wants to extend kernel in a way that it
> > will be possible to do something that was not possible before why is
> > this a bad thing? I would agree with you if for my problem was userspace
> > solution, but there is none. The mmap interface is asymmetric in regards
> > to mlock currently. There is MAP_LOCKED, but no MAP_UNLOCKED. Why
> > MAP_LOCKED is useful then?
> 
> Why? Because this is formal LKML reviewing process. I'm reviewing your
> patch for YOU.
> 
I appreciate that, but unfortunately it seems that you are trying to dismiss
my arguments on the basis that _you_ don't find that useful.

> If there is no objective reason, I don't want to continue reviewing.
> 
--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
