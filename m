Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 91F246B0139
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 03:24:26 -0400 (EDT)
Date: Thu, 14 Oct 2010 09:24:21 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
Message-ID: <20101014072421.GA13414@basil.fritz.box>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
 <87sk0a1sq0.fsf@basil.nowhere.org>
 <20101014160217N.fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101014160217N.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: andi@firstfloor.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 14, 2010 at 04:07:12PM +0900, FUJITA Tomonori wrote:
> On Wed, 13 Oct 2010 09:01:43 +0200
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> > >
> > > What this wants to do: 
> > >   allocates a contiguous chunk of pages larger than MAX_ORDER.
> > >   for device drivers (camera? etc..)
> > 
> > I think to really move forward you need a concrete use case
> > actually implemented in tree.
> 
> As already pointed out, some embeded drivers need physcailly
> contignous memory. Currenlty, they use hacky tricks (e.g. playing with
> the boot memory allocators). There are several proposals for this like

Are any of those in mainline? 

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
