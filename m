Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E591E6B01AC
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 20:06:58 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o61073RE014265
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 1 Jul 2010 09:07:04 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A86A545DE51
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 79FBF45DE4F
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:03 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 637DC1DB801D
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:03 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 135CB1DB8019
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 02/11] oom: oom_kill_process() doesn't select kthread child
In-Reply-To: <20100630135503.GA15644@barrios-desktop>
References: <20100630182715.AA4B.A69D9226@jp.fujitsu.com> <20100630135503.GA15644@barrios-desktop>
Message-Id: <20100701085011.DA13.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu,  1 Jul 2010 09:07:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jun 30, 2010 at 06:27:52PM +0900, KOSAKI Motohiro wrote:
> > Now, select_bad_process() have PF_KTHREAD check, but oom_kill_process
> > doesn't. It mean oom_kill_process() may choose wrong task, especially,
> > when the child are using use_mm().
> 
> Is it possible child is kthread even though parent isn't kthread?

Usually unhappen. but crappy driver can do any strange thing freely.
As I said, oom code should have conservative assumption as far as possible.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
