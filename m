Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E67536B004D
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:11:22 -0400 (EDT)
Message-ID: <49C79A04.3000602@redhat.com>
Date: Mon, 23 Mar 2009 10:17:40 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] shmem: writepage directly to swap
References: <Pine.LNX.4.64.0903230151140.11883@blonde.anvils>
In-Reply-To: <Pine.LNX.4.64.0903230151140.11883@blonde.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Rohland <hans-christoph.rohland@sap.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Synopsis: if shmem_writepage calls swap_writepage directly, most shmem swap
> loads benefit, and a catastrophic interaction between SLUB and some flash
> storage is avoided.

> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
