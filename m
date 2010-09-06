Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 80CF76B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 05:02:34 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o8692W79024872
	for <linux-mm@kvack.org>; Mon, 6 Sep 2010 02:02:32 -0700
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz37.hot.corp.google.com with ESMTP id o8692UDp006857
	for <linux-mm@kvack.org>; Mon, 6 Sep 2010 02:02:30 -0700
Received: by pwj4 with SMTP id 4so1043859pwj.32
        for <linux-mm@kvack.org>; Mon, 06 Sep 2010 02:02:30 -0700 (PDT)
Date: Mon, 6 Sep 2010 02:02:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 13/14] mm: mempolicy: Check return code of check_range
In-Reply-To: <20100906093610.C8B5.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009060201000.10552@chino.kir.corp.google.com>
References: <1283711588-7628-1-git-send-email-segooon@gmail.com> <20100906093610.C8B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Kulikov Vasiliy <segooon@gmail.com>, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Sep 2010, KOSAKI Motohiro wrote:

> > From: Vasiliy Kulikov <segooon@gmail.com>
> > 
> > Function check_range may return ERR_PTR(...). Check for it.
> 
> When happen this issue?
> 
> afaik, check_range return error when following condition.
>  1) mm->mmap->vm_start argument is incorrect
>  2) don't have neigher MPOL_MF_STATS, MPOL_MF_MOVE and MPOL_MF_MOVE_ALL
> 
> I think both case is not happen in real. Am I overlooking anything?
> 

There's no reason not to check the return value of a function when the 
implementation of either could change at any time.  migrate_to_node() is 
certainly not in any fastpath where we can't sacrifice a branch for more 
robust code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
