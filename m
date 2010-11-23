Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 37F806B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 18:58:02 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oANNvwDw002034
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 24 Nov 2010 08:57:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DF4745DE52
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 08:57:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4847D45DE51
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 08:57:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 12C981DB8040
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 08:57:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BD3881DB8038
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 08:57:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] mlock: release mmap_sem every 256 faulted pages
In-Reply-To: <AANLkTi=dK9wQaHm=tXOCqN2BDw5jEtH5qfs9zRHbE0qT@mail.gmail.com>
References: <20101122215746.e847742d.akpm@linux-foundation.org> <AANLkTi=dK9wQaHm=tXOCqN2BDw5jEtH5qfs9zRHbE0qT@mail.gmail.com>
Message-Id: <20101124085451.7BE5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 24 Nov 2010 08:57:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > A more compelling description of why this problem needs addressing
> > would help things along.
> 
> Oh my. It's probably not too useful for desktops, where such large
> mlocks are hopefully uncommon.
> 
> At google we have many applications that serve data from memory and
> don't want to allow for disk latencies. Some of the simpler ones use
> mlock (though there are other ways - anon memory running with swap
> disabled is a surprisingly popular choice).
> 
> Kosaki is also showing interest in mlock, though I'm not sure what his
> use case is.

I don't have any solid use case. Usually server app only do mlock anonymous memory.
But, I haven't found any negative effect in your proposal, therefore I hope to help
your effort as I always do when the proposal don't have negative impact.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
