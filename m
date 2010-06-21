Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 019F86B01C7
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 07:47:06 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5LBl4Zc025029
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 21 Jun 2010 20:47:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 87BDE45DE55
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:47:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 822AC45DE51
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:47:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 37A2C1DB8018
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:47:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1000C1DB801A
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:46:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] oom: unify CAP_SYS_RAWIO check into other superuser check
In-Reply-To: <alpine.DEB.2.00.1006162118160.14101@chino.kir.corp.google.com>
References: <20100617104756.FB8F.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162118160.14101@chino.kir.corp.google.com>
Message-Id: <20100621204605.B545.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 21 Jun 2010 20:46:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:
> 
> > 
> > Now, CAP_SYS_RAWIO check is very strange. if the user have both
> > CAP_SYS_ADMIN and CAP_SYS_RAWIO, points will makes 1/16.
> > 
> > Superuser's 1/4 bonus worthness is quite a bit dubious, but
> > considerable. However 1/16 is obviously insane.
> > 
> 
> This is already obsoleted by the heuristic rewrite that is already under 
> review.

Huh? I don't think this patch conflict against your. but I'm ok to pending
awhile.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
