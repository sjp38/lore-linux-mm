Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 579DB6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:54:22 -0400 (EDT)
Message-ID: <4FF20A7C.7070801@sgi.com>
Date: Mon, 2 Jul 2012 15:54:20 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2 v4][rfc] tmpfs not interleaving properly
References: <20120702202635.GA20284@gulag1.americas.sgi.com>
In-Reply-To: <20120702202635.GA20284@gulag1.americas.sgi.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Hugh Dickins <hughd@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On 07/02/2012 03:26 PM, Nathan Zimmer wrote:
> When tmpfs has the memory policy interleaved it always starts allocating at each
> file at node 0.  When there are many small files the lower nodes fill up
> disproportionately.
> This patch spreads out node usage by starting files at nodes other then 0.
> The tmpfs superblock grants an offset for each inode as they are created. Each
> then uses that offset to proved a prefered first node for its interleave in
> the shmem_interleave.
>
> v2: passed preferred node via addr
> v3: using current->cpuset_mem_spread_rotor instead of random_node
> v4: Switching the rotor and attempting to provide an interleave function
> Also splitting the patch into two sections.
>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Nick Piggin <npiggin@gmail.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Nathan T Zimmer <nzimmer@sgi.com>
> ---
>
>   include/linux/mm.h       |    6 ++++++
>   include/linux/shmem_fs.h |    2 ++
>   mm/mempolicy.c           |    4 ++++
>   mm/shmem.c               |   33 ++++++++++++++++++++++++++++++---
>   4 files changed, 42 insertions(+), 3 deletions(-)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

I apologize, it seems I have sent the patch before running checkpatch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
