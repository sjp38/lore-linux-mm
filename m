Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AE8DD6B0104
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 03:17:28 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D7HQlj030299
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Oct 2010 16:17:26 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E8B1345DE55
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:17:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE98845DE4E
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:17:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A57A9E18005
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:17:25 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F6F3E08002
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:17:25 +0900 (JST)
Date: Wed, 13 Oct 2010 16:12:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
Message-Id: <20101013161206.c29df8ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <87sk0a1sq0.fsf@basil.nowhere.org>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<87sk0a1sq0.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, fujita.tomonori@lab.ntt.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 13 Oct 2010 09:01:43 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> >
> > What this wants to do: 
> >   allocates a contiguous chunk of pages larger than MAX_ORDER.
> >   for device drivers (camera? etc..)
> 
> I think to really move forward you need a concrete use case
> actually implemented in tree.
> 

yes. I heard there were users at LinuxCon Japan, so restarted.
I heared video-for-linux + ARM wants this.

I found this thread, now.
http://kerneltrap.org/mailarchive/linux-kernel/2010/10/10/4630166

Hmm. 

> >   My intention is not for allocating HUGEPAGE(> MAX_ORDER).
> 
> I still believe using this for 1GB pages would be one of the more
> interesting use cases.
> 

I'm successfully allocating 1GB of continous pages at test. But I'm not sure
requirements and users. How quick this allocation should be ?
For example, if prep_new_page() for 1GB page is slow, what kind of chunk-of-page
construction is the best. 

THanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
