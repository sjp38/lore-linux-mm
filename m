Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6DDC96B02A7
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 23:19:18 -0400 (EDT)
Message-ID: <4C466730.1070809@opengridcomputing.com>
Date: Tue, 20 Jul 2010 22:19:12 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
Subject: Re: [patch 2/6] infiniband: remove dependency on __GFP_NOFAIL
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com> <alpine.DEB.2.00.1007201938570.8728@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1007201938570.8728@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Steve Wise <swise@chelsio.com>, Andrew Morton <akpm@linux-foundation.org>, Roland Dreier <rolandd@cisco.com>, linux-rdma@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Acked-by: Steve Wise <swise@opengridcomputing.com>

David Rientjes wrote:
> The alloc_skb() in various allocations are failable, so remove
> __GFP_NOFAIL from their masks.
>
> Cc: Roland Dreier <rolandd@cisco.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  drivers/infiniband/hw/cxgb4/cq.c  |    4 ++--
>  drivers/infiniband/hw/cxgb4/mem.c |    2 +-
>  drivers/infiniband/hw/cxgb4/qp.c  |    6 +++---
>  3 files changed, 6 insertions(+), 6 deletions(-)
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
