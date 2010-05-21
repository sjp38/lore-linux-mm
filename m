Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E660D6B01B4
	for <linux-mm@kvack.org>; Thu, 20 May 2010 20:15:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4L0FaFX001957
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 21 May 2010 09:15:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06D3745DE51
	for <linux-mm@kvack.org>; Fri, 21 May 2010 09:15:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D998E45DE4F
	for <linux-mm@kvack.org>; Fri, 21 May 2010 09:15:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C10D91DB8038
	for <linux-mm@kvack.org>; Fri, 21 May 2010 09:15:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CCC4E08006
	for <linux-mm@kvack.org>; Fri, 21 May 2010 09:15:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 5/5] vmscan: remove may_swap scan control
In-Reply-To: <20100519214459.GD2868@cmpxchg.org>
References: <20100513122935.2161.A69D9226@jp.fujitsu.com> <20100519214459.GD2868@cmpxchg.org>
Message-Id: <20100521081534.1E31.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 21 May 2010 09:15:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, May 13, 2010 at 12:36:12PM +0900, KOSAKI Motohiro wrote:
> > > The may_swap scan control flag can be naturally merged into the
> > > swappiness parameter: swap only if swappiness is non-zero.
> > 
> > Sorry, NAK.
> > 
> > AFAIK, swappiness==0 is very widely used in MySQL users community.
> > They expect this parameter mean "very prefer to discard file cache 
> > rather than swap, but not completely disable swap".
> > 
> > We shouldn't ignore the real world use case. even if it is a bit strange.
> 
> Bummer.  It's really ugly to have 'zero' mean 'almost nothing'.
> 
> But since swappiness is passed around as an int, I think we can
> instead use -1 for 'no swap'.  Let me look into it and send a
> follow-up patch for this as well.
> 
> Thanks!

Yup, -1 is perfectly acceptable.

Moreover, I hope such strange habbit will disappear int the future.
I think our recent activity help to change their mind.
At that time, we can change the code more radically.


Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
