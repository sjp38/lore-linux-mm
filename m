Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1978D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 20:52:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AFB693EE0C0
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:52:25 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 956B945DE4D
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:52:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6944E45DE4F
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:52:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5402DE78003
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:52:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 215CF1DB802F
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 09:52:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
In-Reply-To: <20110330233050.GG21838@one.firstfloor.org>
References: <20110330144507.2c0ecf73.akpm@linux-foundation.org> <20110330233050.GG21838@one.firstfloor.org>
Message-Id: <20110331095251.0EC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 31 Mar 2011 09:52:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> > Do we still want it?  Are we sure we don't want the per-zone numbers?
> 
> At least I still want it and Dave Hansen did too.
> 
> I don't need per zone personally and I remember a strong request from 
> anyone.  Or was there one?

If my remember is correct, Only /me puted weak request of per-zone number.
To be honest, myself never use this counter, my question was just curious.
Then, I'm ok if Andi didn't hit any issue.

Andi, But, if anyone will put numa request or numa related bug report 
in future, Perhaps I might convert it per-zone one. Is this ok?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
