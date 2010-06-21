Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 55C8E6B0071
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 07:45:50 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5LBjlUk024530
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 21 Jun 2010 20:45:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D78CA45DE7B
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 89C6745DE4D
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 71452E38003
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BC481DB803E
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 20:45:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/9] oom: cleanup has_intersects_mems_allowed()
In-Reply-To: <alpine.DEB.2.00.1006162119540.14101@chino.kir.corp.google.com>
References: <20100617104719.FB8C.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006162119540.14101@chino.kir.corp.google.com>
Message-Id: <20100617134601.FBA7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Mon, 21 Jun 2010 20:45:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 17 Jun 2010, KOSAKI Motohiro wrote:
> 
> > 
> > Now has_intersects_mems_allowed() has own thread iterate logic, but
> > it should use while_each_thread().
> > 
> > It slightly improve the code readability.
> > 
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> I disagree that the renaming of the variables is necessary, please simply 
> change the while (tsk != start) to use while_each_thread(tsk, start);

This is common naming rule of while_each_thread(). please grep.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
