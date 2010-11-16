Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 439B18D0080
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 23:54:09 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG4s6YB032040
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Nov 2010 13:54:06 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 525A145DE55
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:54:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 312CF45DE4E
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:54:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 127E2E08003
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:54:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C524EE08002
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:54:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH/RFC 0/8] numa - Migrate-on-Fault
In-Reply-To: <alpine.DEB.2.00.1011150809030.19175@router.home>
References: <20101114152440.E02E.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011150809030.19175@router.home>
Message-Id: <20101116134644.BF21.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Nov 2010 13:54:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, andi@firstfloor.org, David Rientjes <rientjes@google.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:
> 
> > Nice!
> 
> Lets not get overenthused. There has been no conclusive proof that the
> overhead introduced by automatic migration schemes is consistently less
> than the benefit obtained by moving the data. Quite to the contrary. We
> have over a decades worth of research and attempts on this issue and there
> was no general improvement to be had that way.
> 
> The reason that the manual placement interfaces exist is because there was
> no generally beneficial migration scheme available. The manual interfaces
> allow the writing of various automatic migrations schemes in user space.
> 
> If wecan come up with something that is an improvement then lets go
> this way but I am skeptical.

Ah, I thought this series only has manua migration (i.e. MPOL_MF_LAZY),
but it also has automatic migration if a page is not mapped. So my standpoint
is, manual lazy migration has certinally usecase. but I have no opinion against
automatic one.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
