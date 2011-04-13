Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 97EFD900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 04:34:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 060333EE0BC
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:34:37 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DF5CC45DE56
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:34:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C55F045DE51
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:34:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B1DB61DB8043
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:34:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7973F1DB803B
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 17:34:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
In-Reply-To: <1302678049.28876.77.camel@pasglop>
References: <20110413064432.GA4098@p183> <1302678049.28876.77.camel@pasglop>
Message-Id: <20110413173453.D734.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed, 13 Apr 2011 17:34:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

> On Wed, 2011-04-13 at 09:44 +0300, Alexey Dobriyan wrote:
> > > Yes, I take Hugh's version because vm_flags_t is ugly to me. And
> > arch 
> > > dependent variable size is problematic.
> > 
> > Who said it should have arch-dependent size? 
> 
> Right, it shouldn't. My original patch did that to avoid thinking about
> archs that manipulated it from asm such as ARM but that wasn't the right
> thing to do. But that doesn't invalidate having a type.

type or not type is really cosmetic matter. Then, only if Andrew or Hugh
or another active MM developers strongly requrest to make a type, I'll do.
But, now I haven't hear it.

In short, When both are right code, I prefer to take MM developers preference.
That's MM code. This is the reason why I taked Hugh's choice.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
