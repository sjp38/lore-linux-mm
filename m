Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6173B6B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 20:03:04 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8702xXI011511
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 7 Sep 2010 09:03:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8622545DE53
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:02:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1977545DE50
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:02:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F09571DB8012
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:02:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7827F1DB8014
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:02:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 13/14] mm: mempolicy: Check return code of check_range
In-Reply-To: <alpine.DEB.2.00.1009060201000.10552@chino.kir.corp.google.com>
References: <20100906093610.C8B5.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009060201000.10552@chino.kir.corp.google.com>
Message-Id: <20100907090220.C8D5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  7 Sep 2010 09:02:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Kulikov Vasiliy <segooon@gmail.com>, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 6 Sep 2010, KOSAKI Motohiro wrote:
> 
> > > From: Vasiliy Kulikov <segooon@gmail.com>
> > > 
> > > Function check_range may return ERR_PTR(...). Check for it.
> > 
> > When happen this issue?
> > 
> > afaik, check_range return error when following condition.
> >  1) mm->mmap->vm_start argument is incorrect
> >  2) don't have neigher MPOL_MF_STATS, MPOL_MF_MOVE and MPOL_MF_MOVE_ALL
> > 
> > I think both case is not happen in real. Am I overlooking anything?
> > 
> 
> There's no reason not to check the return value of a function when the 
> implementation of either could change at any time.  migrate_to_node() is 
> certainly not in any fastpath where we can't sacrifice a branch for more 
> robust code.

I was not against this change. I was asking patch effectness.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
