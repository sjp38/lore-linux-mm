Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A7F4C900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 01:33:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1D34D3EE0B6
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:33:03 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 059D645DE67
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:33:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E0AAF45DE61
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:33:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D4FB61DB8038
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:33:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A23B01DB802C
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:33:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] make sparse happy with gfp.h
In-Reply-To: <1302844066.16562.1953.camel@nimitz>
References: <20110415121424.F7A6.A69D9226@jp.fujitsu.com> <1302844066.16562.1953.camel@nimitz>
Message-Id: <20110415143259.F7BD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 15 Apr 2011 14:33:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Hello,

> On Fri, 2011-04-15 at 12:14 +0900, KOSAKI Motohiro wrote:
> > >  #ifdef CONFIG_DEBUG_VM
> > > -             BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > > +     BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > >  #endif
> > > -     }
> > >       return z;
> > 
> > Why don't you use VM_BUG_ON?
> 
> I was just trying to make a minimal patch that did a single thing.
> 
> Feel free to submit another one that does that.  I'm sure there are a
> couple more places that could use similar love.

I posted another approach patches a second ago. Could you please see it?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
