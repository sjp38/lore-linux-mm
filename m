Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3D1776B02A3
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 20:14:22 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D0EIpn027249
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Jul 2010 09:14:18 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A458C45DE51
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 09:14:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7946A45DE56
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 09:14:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 573461DB8038
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 09:14:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C71AE1DB805A
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 09:14:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: FYI: mmap_sem OOM patch
In-Reply-To: <alpine.DEB.2.00.1007121446500.8468@chino.kir.corp.google.com>
References: <20100708200324.CD4B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1007121446500.8468@chino.kir.corp.google.com>
Message-Id: <20100713091333.EA3E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Jul 2010 09:14:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> On Thu, 8 Jul 2010, KOSAKI Motohiro wrote:
> 
> > I disagree. __GFP_NOFAIL mean this allocation failure can makes really
> > dangerous result. Instead, OOM-Killer should try to kill next process.
> > I think.
> > 
> 
> That's not what happens, __alloc_pages_high_priority() will loop forever 
> for __GFP_NOFAIL, the oom killer is never recalled.

Yup, please reread the discusstion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
