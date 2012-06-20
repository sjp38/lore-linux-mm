Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 873E06B005D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 13:09:17 -0400 (EDT)
Message-ID: <4FE20378.70105@redhat.com>
Date: Wed, 20 Jun 2012 13:08:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/12] mm: Add support for direct_IO to highmem pages
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1340185081-22525-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> The patch "mm: Add support for a filesystem to activate swap files and
> use direct_IO for writing swap pages" added support for using direct_IO
> to write swap pages but it is insufficient for highmem pages.
>
> To support highmem pages, this patch kmaps() the page before calling the
> direct_IO() handler. As direct_IO deals with virtual addresses an
> additional helper is necessary for get_kernel_pages() to lookup the
> struct page for a kmap virtual address.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel<riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
