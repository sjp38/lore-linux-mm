Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 65E246B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 01:31:24 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAI6VLHE011845
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 18 Nov 2009 15:31:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5577B45DE57
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 15:31:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EB40C45DE55
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 15:31:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B932A1DB8043
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 15:31:20 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CB0B1DB805E
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 15:31:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/7] cifs: Don't use PF_MEMALLOC
In-Reply-To: <524f69650911170840o5be241a0q5d9863c8d7f4e571@mail.gmail.com>
References: <20091117074739.4abaef85@tlielax.poochiereds.net> <524f69650911170840o5be241a0q5d9863c8d7f4e571@mail.gmail.com>
Message-Id: <20091118152007.3E1D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 18 Nov 2009 15:31:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Steve French <smfrench@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Jeff Layton <jlayton@redhat.com>, LKML <linux-kernel@vger.kernel.org>, samba-technical@lists.samba.org, Steve French <sfrench@samba.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-cifs-client@lists.samba.org
List-ID: <linux-mm.kvack.org>

> It is hard to follow exactly what this flag does in /mm (other than try
> harder on memory allocations) - I haven't found much about this flag (e.g.
> http://lwn.net/Articles/246928/) but it does look like most of the fs no
> longer set this (except xfs) e.g. ext3_ordered_writepage.  When running out
> of memory in the cifs_demultiplex_thread it will retry 3 seconds later, but
> if memory allocations ever fail in this path we could potentially be holding
> up (an already issued write in) writepages for that period by not having
> memory to get the response to see if the write succeeded.
> 
> We pass in few flags for these memory allocation requests: GFP_NOFS (on the
> mempool_alloc) and SLAB_HWCACHE_ALIGN (on the kmem_cache_create of the pool)
> should we be passing in other flags on the allocations?

I don't think you  need change more.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
