Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CCCDE6B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 23:08:30 -0500 (EST)
Date: Fri, 27 Feb 2009 20:08:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: get_nid_for_pfn() returns int
Message-Id: <20090227200805.23d27aa1.akpm@linux-foundation.org>
In-Reply-To: <20090228030200.GA7342@us.ibm.com>
References: <4973AEEC.70504@gmail.com>
	<20090119175919.GA7476@us.ibm.com>
	<20090126223350.610b0283.akpm@linux-foundation.org>
	<20090127210727.GA9592@us.ibm.com>
	<25e057c00902270656x1781d04er5703058e47df455f@mail.gmail.com>
	<20090227213340.GB7174@us.ibm.com>
	<20090227134616.982fb73a.akpm@linux-foundation.org>
	<20090228001400.GC7174@us.ibm.com>
	<20090227162249.bcd0813a.akpm@linux-foundation.org>
	<20090228030200.GA7342@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gary Hade <garyhade@us.ibm.com>
Cc: roel.kluin@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 27 Feb 2009 19:02:00 -0800 Gary Hade <garyhade@us.ibm.com> wrote:

> > > > Should it unlinger?  I have it in the 2.6.30 pile.
> > > 
> > > Yes, that would be good. :)
> > 
> > What would be good?  Your answer is ambiguous.
> 
> Sorry, I was just trying to agree that your plan to wait
> until 2.6.30 works for me.  Unless someone else objects
> leave it in your 2.6.30 pile.

I object ;)

The change is obviously correct, let's merge it now.

This could cause presently-working systems to stop working due to
hitherto-undiscovered bugs.  If so, sue me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
