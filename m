Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 534556B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 02:30:59 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0E7UqNi015897
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 16:30:53 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7510545DE50
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:30:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F29D45DE4E
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:30:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 242F4E08002
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:30:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C177B1DB803B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:30:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v5] add MAP_UNLOCKED mmap flag
In-Reply-To: <20100114072210.GK18808@redhat.com>
References: <20100114155229.6735.A69D9226@jp.fujitsu.com> <20100114072210.GK18808@redhat.com>
Message-Id: <20100114162327.673E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Jan 2010 16:30:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> On Thu, Jan 14, 2010 at 04:02:42PM +0900, KOSAKI Motohiro wrote:
> > > On Thu, Jan 14, 2010 at 09:31:03AM +0900, KOSAKI Motohiro wrote:
> > > > > If application does mlockall(MCL_FUTURE) it is no longer possible to mmap
> > > > > file bigger than main memory or allocate big area of anonymous memory
> > > > > in a thread safe manner. Sometimes it is desirable to lock everything
> > > > > related to program execution into memory, but still be able to mmap
> > > > > big file or allocate huge amount of memory and allow OS to swap them on
> > > > > demand. MAP_UNLOCKED allows to do that.
> > > > >  
> > > > > Signed-off-by: Gleb Natapov <gleb@redhat.com>
> > > > > ---
> > > > > 
> > > > > I get reports that people find this useful, so resending.
> > > > 
> > > > This description is still wrong. It doesn't describe why this patch is useful.
> > > > 
> > > I think the text above describes the feature it adds and its use
> > > case quite well. Can you elaborate what is missing in your opinion,
> > > or suggest alternative text please?
> > 
> > My point is, introducing mmap new flags need strong and clearly use-case.
> > All patch should have good benefit/cost balance. the code can describe the cost,
> > but the benefit can be only explained by the patch description.
> > 
> > I don't think this poor description explained bit benefit rather than cost.
> > you should explain why this patch is useful and not just pretty toy.
> > 
> The benefit is that with this patch I can lock all of my application in
> memory except some very big memory areas. My use case is that I want to
> run virtual machine in such a way that everything related to machine
> emulator is locked into the memory, but guest address space can be
> swapped out at will. Guest address space is so huge that it is not
> possible to allocated it locked and then unlock. I was very surprised
> that current Linux API has no way to do it hence this patch. It may look
> like a pretty toy to you until some day you need this and has no way to
> do it.

Hmm..
Your answer didn't match I wanted.
few additional questions.

- Why don't you change your application? It seems natural way than kernel change.
- Why do you want your virtual machine have mlockall? AFAIK, current majority
  virtual machine doesn't.
- If this feature added, average distro user can get any benefit?

I mean, many application developrs want to add their specific feature
into kernel. but if we allow it unlimitedly, major syscall become
the trushbox of pretty toy feature soon.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
