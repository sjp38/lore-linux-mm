Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id F3DDC6B004D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 12:09:14 -0400 (EDT)
Message-ID: <4FE1F564.6070107@redhat.com>
Date: Wed, 20 Jun 2012 12:08:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/12] mm: Add support for a filesystem to activate swap
 files and use direct_IO for writing swap pages
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1340185081-22525-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> Currently swapfiles are managed entirely by the core VM by using ->bmap
> to allocate space and write to the blocks directly. This effectively
> ensures that the underlying blocks are allocated and avoids the need
> for the swap subsystem to locate what physical blocks store offsets
> within a file.
>
> If the swap subsystem is to use the filesystem information to locate
> the blocks, it is critical that information such as block groups,
> block bitmaps and the block descriptor table that map the swap file
> were resident in memory. This patch adds address_space_operations that
> the VM can call when activating or deactivating swap backed by a file.
>
>    int swap_activate(struct file *);
>    int swap_deactivate(struct file *);

Acked-by: Rik van Riel<riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
