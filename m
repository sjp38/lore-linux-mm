Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B08496B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 20:09:50 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9D02A3EE0C1
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:09:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ED9B45DE5B
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:09:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EB5945DE56
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:09:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CD301DB8057
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:09:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 095801DB8048
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:09:46 +0900 (JST)
Date: Fri, 26 Aug 2011 09:02:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure
 changes
Message-Id: <20110826090214.2f7f2cdc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <8a95a804-7ba3-416e-9ba5-8da7b9cabba5@default>
References: <20110823145755.GA23174@ca-server1.us.oracle.com
 20110825143312.a6fe93d5.kamezawa.hiroyu@jp.fujitsu.com>
	<8a95a804-7ba3-416e-9ba5-8da7b9cabba5@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

On Thu, 25 Aug 2011 10:11:11 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> > From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> > Subject: Re: Subject: [PATCH V7 1/4] mm: frontswap: swap data structure changes
> 
> Hi Kamezawa-san --
> 
> Domo arigato for the review and feedback!
> 
> > Hmm....could you modify mm/swapfile.c and remove 'static' in the same patch ?
> 
> I separated out this header patch because I thought it would
> make the key swap data structure changes more visible.  Are you
> saying that it is more confusing?

Yes. I know you add a new header file which is not included but..


At reviewing patch, I check whether all required changes are done.
In this case, you turned out the function to be externed but you
leave the function definition as 'static'. This unbalance confues me.

I always read patches from 1 to END. When I found an incomplete change
in patch 1, I remember it and need to find missng part from patch 2->End. 
This makes my review confused a little.

In another case, when a patch adds a new file, I check Makefile change.
Considering dependency, the patch order should be

	[patch 1] Documentaion/Config
	[patch 2] Makefile + add new file.

But plesse note: This is my thought. Other guys may have other idea.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
