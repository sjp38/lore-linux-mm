Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A273C6B00A7
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:40:02 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8S5Z0oi003610
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Sep 2009 14:35:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ADD9B45DE51
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 14:35:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B15E45DE4F
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 14:35:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 44615E08006
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 14:35:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DA711E08010
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 14:34:59 +0900 (JST)
Date: Mon, 28 Sep 2009 14:32:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-Id: <20090928143246.ffed3413.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4AC04800.70708@crca.org.au>
References: <4AB9A0D6.1090004@crca.org.au>
	<20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>
	<4ABC80B0.5010100@crca.org.au>
	<20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC0234F.2080808@crca.org.au>
	<20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090928033624.GA11191@localhost>
	<20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC03D9C.3020907@crca.org.au>
	<20090928135315.083aca18.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC04800.70708@crca.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Sep 2009 15:22:08 +1000
Nigel Cunningham <ncunningham@crca.org.au> wrote:

> Hi.
> 
> KAMEZAWA Hiroyuki wrote:
> > Seems good to me.
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > But
> >> +	if (vma->vm_hints)
> >> +		return 0;
> >>  	return 1;
> > 
> > Maybe adding a comment (or more detailed patch description) is necessary.
> 
> Thinking about this some more, I think we should also be looking at whether the new hints are non zero. Perhaps I should just add the new value to the
> function parameters and be done with it.
> 
No objections from me. plz do.
I said option (1) just because patch size will be big to unexpected.
Thank you for your effort.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
