Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id CECC86B0078
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:32:43 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id o8so4076141qcw.31
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:32:43 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTP id i10si12341670qas.118.2014.06.20.13.32.42
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 13:32:43 -0700 (PDT)
Date: Fri, 20 Jun 2014 15:32:40 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: kernel BUG at /src/linux-dev/mm/mempolicy.c:1738! on v3.16-rc1
In-Reply-To: <alpine.LSU.2.11.1406201257370.8123@eggly.anvils>
Message-ID: <alpine.DEB.2.11.1406201531530.5221@gentwo.org>
References: <20140619215641.GA9792@nhori.bos.redhat.com> <alpine.DEB.2.11.1406200923220.10271@gentwo.org> <20140620194639.GA30729@nhori.bos.redhat.com> <alpine.LSU.2.11.1406201257370.8123@eggly.anvils>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 20 Jun 2014, Hugh Dickins wrote:

> [PATCH] mm: fix crashes from mbind() merging vmas
>
> v2.6.34's 9d8cebd4bcd7 ("mm: fix mbind vma merge problem") introduced
> vma merging to mbind(), but it should have also changed the convention
> of passing start vma from queue_pages_range() (formerly check_range())
> to new_vma_page(): vma merging may have already freed that structure,
> resulting in BUG at mm/mempolicy.c:1738 and probably worse crashes.

Good catch. Cannot find fault with what I see.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
