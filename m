Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id EE5126B005A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 04:18:19 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1StDqL-0008MM-4j
	for linux-mm@kvack.org; Mon, 23 Jul 2012 10:18:17 +0200
Received: from 112.132.186.225 ([112.132.186.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 10:18:17 +0200
Received: from xiyou.wangcong by 112.132.186.225 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 10:18:17 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH RESEND v4 1/3] mm/sparse: optimize sparse_index_alloc
Date: Mon, 23 Jul 2012 08:18:04 +0000 (UTC)
Message-ID: <juj1bs$qh3$1@dough.gmane.org>
References: <1343010702-28720-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Mon, 23 Jul 2012 at 02:31 GMT, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
> With CONFIG_SPARSEMEM_EXTREME, the two level of memory section
> descriptors are allocated from slab or bootmem. When allocating
> from slab, let slab/bootmem allocator to clear the memory chunk.
> We needn't clear that explicitly.
>
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: David Rientjes <rientjes@google.com>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
