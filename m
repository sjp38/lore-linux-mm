Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 196776B01AF
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 06:54:49 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o54AskrZ025933
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Jun 2010 19:54:46 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 87B1145DE51
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 641A945DE4E
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 470191DB8038
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D557F1DB8043
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 09/12] oom: remove PF_EXITING check completely
In-Reply-To: <alpine.DEB.2.00.1006022332320.22441@chino.kir.corp.google.com>
References: <20100603152436.7262.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006022332320.22441@chino.kir.corp.google.com>
Message-Id: <20100604092414.7292.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Fri,  4 Jun 2010 19:54:42 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Acked-by: Oleg Nesterov <oleg@redhat.com>
> 
> Nacked-by: David Rientjes <rientjes@google.com>
> 
> You have no real world experience in using the oom killer for memory 
> containment and don't understand how critical it is to protect other 
> vital system tasks that are needlessly killed as the result of this patch.

Heh, You really think "you have no experience" takes meaningful argument?
If I'd say "You have no real world experience in using linux", you are
satisfied?

Anyway, I don't care such "Please don't fix the bug" claim. the bug is
bug. not something else.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
