Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D9CE96B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 00:20:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 034743EE0BD
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 13:20:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D281745DEB4
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 13:20:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA55E45DE9E
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 13:20:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A582C1DB8042
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 13:20:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 53A051DB803E
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 13:20:36 +0900 (JST)
Date: Fri, 4 Nov 2011 13:19:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-Id: <20111104131932.ccafb402.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <785a9dc0-2f15-40bf-b9a8-e3ab28e650bd@default>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
	<20111031171321.097a166c.kamezawa.hiroyu@jp.fujitsu.com>
	<ef778e79-72d0-4c58-99e8-3b36d85fa30d@default>
	<20111101095038.30289914.kamezawa.hiroyu@jp.fujitsu.com>
	<f62e02cd-fa41-44e8-8090-efe2ef052f64@default
 20111102101414.457e0a08.kamezawa.hiroyu@jp.fujitsu.com>
	<785a9dc0-2f15-40bf-b9a8-e3ab28e650bd@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

On Wed, 2 Nov 2011 08:12:01 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > > Kame, can I add you to the list of people who support
> > > merging frontswap, assuming more good performance numbers
> > > are posted?
> 
> So I'm not asking you if Fujitsu enterprise QoS-guarantee
> customers will use zcache.... Andrew said yesterday:
> 
> "At kernel summit there was discussion and overall agreement
>  that we've been paying insufficient attention to the
>  big-picture "should we include this feature at all" issues.
>  We resolved to look more intensely and critically at new
>  features with a view to deciding whether their usefulness
>  justified their maintenance burden."
> 
> I am asking you, who are an open source Linux developer and
> a respected -mm developer, do you think the usefulness
> of frontswap justifies the maintenance burden, and frontswap
> should be merged?
> 

When you convince other guys that the design is good.
At reading the whole threads, it seems other deveoppers raise
2 problems.
  1. justification of usage
  2. API design.

For 1, you'll need to show performance and benefits. I think
you tried and you'll do, again. But please take care of "2", it
seems some guys (Rik and Andrea) has concerns. 

Please CC me, I'd like to join code review process, at least.
I'd like to think of a new usage for frontswap/cleancache benficial
for enterprise users.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
