Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9H9XkvQ027196
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Oct 2008 18:33:46 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DA8F240047
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 18:33:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 061A92DC077
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 18:33:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DCB7F1DB8040
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 18:33:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F1991DB803A
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 18:33:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch][rfc] mm: have expand_stack honour VM_LOCKED
In-Reply-To: <20081017182737.E23C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081017090813.GA32554@wotan.suse.de> <20081017182737.E23C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081017183247.E23F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Oct 2008 18:33:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I see. thanks.
> 
> But unfortunately, this patch conflicted against unevictable patch series.
> I'll make for -mm version patch few days after if you don't like do that.
                                                              ^^^^
                                                              dislike I do that.

HAHAHA, I am very stupid guy.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
