Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 37E528D0001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 19:33:54 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAQ0Xp9j003719
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 26 Nov 2010 09:33:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 272A745DE55
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 09:33:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AEC045DE58
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 09:33:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F1CA5E38001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 09:33:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BF916E08002
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 09:33:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101125171313.GA15899@hostway.ca>
References: <20101125191759.F465.A69D9226@jp.fujitsu.com> <20101125171313.GA15899@hostway.ca>
Message-Id: <20101126093326.B6D0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 26 Nov 2010 09:33:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

> On Thu, Nov 25, 2010 at 07:18:49PM +0900, KOSAKI Motohiro wrote:
> 
> > This?
> 
> > -	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
> > +	alloc_gfp = (flags | __GFP_NOWARN) & ~(__GFP_NOFAIL | __GFP_WAIT);
> 
> kswapd still gets woken in the !__GFP_WAIT case, which is what I was
> seeing anyway, because the order-3 allocatons were starting from
> __alloc_skb().

Oops, my fault.
We also need __GFP_NOKSWAPD. (Proposed by Andrea)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
