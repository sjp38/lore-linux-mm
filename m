Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C9EF76B002D
	for <linux-mm@kvack.org>; Thu, 20 Oct 2011 23:19:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 12E2D3EE0BB
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 12:19:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E028845DE51
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 12:19:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C719645DE4E
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 12:19:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B88A81DB803E
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 12:19:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 85BC11DB802F
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 12:19:13 +0900 (JST)
Date: Fri, 21 Oct 2011 12:17:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFD] Isolated memory cgroups again
Message-Id: <20111021121759.429d8222.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111021024554.GC2589@tiehlicka.suse.cz>
References: <20111020013305.GD21703@tiehlicka.suse.cz>
	<CALWz4ixxeFveibvqYa4cQR1a4fEBrTrTUFwm2iajk9mV0MEiTw@mail.gmail.com>
	<20111021024554.GC2589@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Kir Kolyshkin <kir@parallels.com>, Pavel Emelianov <xemul@parallels.com>, GregThelen <gthelen@google.com>, "pjt@google.com" <pjt@google.com>, Tim Hockin <thockin@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <paul@paulmenage.org>, James Bottomley <James.Bottomley@hansenpartnership.com>

On Thu, 20 Oct 2011 19:45:55 -0700
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 20-10-11 16:41:27, Ying Han wrote:
> [...]
> > Hi Michal:
> 
> Hi,
> 
> > 
> > I didn't read through the patch itself but only the description. If we
> > wanna protect a memcg being reclaimed from under global memory
> > pressure, I think we can approach it by making change on soft_limit
> > reclaim.
> > 
> > I have a soft_limit change built on top of Johannes's patchset, which
> > does basically soft_limit aware reclaim under global memory pressure.
> 
> Is there any link to the patch(es)? I would be interested to look at
> it before we discuss it.
> 

I'd like to see it, too.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
