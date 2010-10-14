Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6072D6B013B
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 04:36:43 -0400 (EDT)
Date: Thu, 14 Oct 2010 17:36:28 +0900
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20101014072421.GA13414@basil.fritz.box>
References: <87sk0a1sq0.fsf@basil.nowhere.org>
	<20101014160217N.fujita.tomonori@lab.ntt.co.jp>
	<20101014072421.GA13414@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20101014173103U.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: andi@firstfloor.org
Cc: fujita.tomonori@lab.ntt.co.jp, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Oct 2010 09:24:21 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> On Thu, Oct 14, 2010 at 04:07:12PM +0900, FUJITA Tomonori wrote:
> > On Wed, 13 Oct 2010 09:01:43 +0200
> > Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> > > >
> > > > What this wants to do: 
> > > >   allocates a contiguous chunk of pages larger than MAX_ORDER.
> > > >   for device drivers (camera? etc..)
> > > 
> > > I think to really move forward you need a concrete use case
> > > actually implemented in tree.
> > 
> > As already pointed out, some embeded drivers need physcailly
> > contignous memory. Currenlty, they use hacky tricks (e.g. playing with
> > the boot memory allocators). There are several proposals for this like
> 
> Are any of those in mainline? 

The tricks or the proposals?

I think that at least one mainline driver in arm uses such trick but I
can't recall the name. Better to ask on the arm mainling list. Also I
heard that the are some out-of-tree patches about this.


I think that any such proposal hasn't merged yet. If you are looking
for such examples, here's one:

http://lwn.net/Articles/401107/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
