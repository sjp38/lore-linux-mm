Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E46E68D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:33:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B66903EE0AE
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:33:27 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 92BCF45DE99
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:33:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6289145DE95
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:33:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52633E0800B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:33:27 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C6CCE08007
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:33:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH followup] mm: get rid of CONFIG_STACK_GROWSUP || CONFIG_IA64
In-Reply-To: <20110419110956.GD21689@tiehlicka.suse.cz>
References: <20110419091022.GA21689@tiehlicka.suse.cz> <20110419110956.GD21689@tiehlicka.suse.cz>
Message-Id: <20110420093326.45EF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Apr 2011 09:33:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

> While I am in the cleanup mode. We should use VM_GROWSUP rather than
> tricky CONFIG_STACK_GROWSUP||CONFIG_IA64.
> 
> What do you think?

Now, VM_GROWSUP share the same value with VM_NOHUGEPAGE.
(this trick use the fact that thp don't support any stack growup architecture)

So, No.
Sorry for that.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
