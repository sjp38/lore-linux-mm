Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 435CA6B004D
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:13:47 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BB87282C4C8
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:55:45 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jLYBIuO70Vlj for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 09:55:45 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C1FA582C4E2
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:55:40 -0400 (EDT)
Date: Thu, 1 Oct 2009 09:47:35 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: No more bits in vm_area_struct's vm_flags.
In-Reply-To: <Pine.LNX.4.64.0910011134240.10818@sister.anvils>
Message-ID: <alpine.DEB.1.10.0910010944480.26219@gentwo.org>
References: <4AB9A0D6.1090004@crca.org.au> <20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com> <4ABC80B0.5010100@crca.org.au> <20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com> <4AC0234F.2080808@crca.org.au> <20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>
 <20090928033624.GA11191@localhost> <20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0909281637160.25798@sister.anvils> <a0ea21a7cfe313202e2b51510aa5435a.squirrel@webmail-b.css.fujitsu.com> <Pine.LNX.4.64.0909282134100.11529@sister.anvils>
 <20090929105735.06eea1ee.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.1.10.0909291019100.15549@gentwo.org> <Pine.LNX.4.64.0910011134240.10818@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Nigel Cunningham <ncunningham@crca.org.au>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Oct 2009, Hugh Dickins wrote:

> Are we doing that?  If you have some example like, when PG_slab is set
> then PG_owner_priv_1 means such-and-such, but if not not: okay, I'm
> fine with that.

Look at how compound pages are handled in include/linux/page-flags.h

> But if you're saying something like, if PG_reclaim is set at the same
> time as PG_buddy, then they mean the page is not a buddy or under
> reclaim, but brokenbacked: then I'm a bit (or even 32 bits) worried.

Of course you need to be careful not to use two bits that can be used
indepedently.

> > VM_HUGETLB cannot grow up and down f.e. and there are
> > certainly lots of other impossible combinations that can be used to put
> > more information into the flags.
>
> Where it makes sense, where it's understandable, okay: there may be a
> few which could naturally use combinations.  But in general, no, I
> think we'd be asking for endless maintenance trouble if we change the
> meaning of some flags according to other flags.

We made the page flags stuff configurable. On 64 bit we use more flags, on
32 bit we compress the page flags a bit. Maybe do the same for vm_flags?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
