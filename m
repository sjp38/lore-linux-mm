Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 34B606B0070
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 11:34:52 -0400 (EDT)
Message-ID: <4FE1ED55.5070708@redhat.com>
Date: Wed, 20 Jun 2012 11:33:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/12] selinux: tag avc cache alloc as non-critical
References: <1340185081-22525-1-git-send-email-mgorman@suse.de> <1340185081-22525-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1340185081-22525-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On 06/20/2012 05:37 AM, Mel Gorman wrote:
> Failing to allocate a cache entry will only harm performance not
> correctness.  Do not consume valuable reserve pages for something
> like that.
>
> Signed-off-by: Peter Zijlstra<a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman<mgorman@suse.de>
> Acked-by: Eric Paris<eparis@redhat.com>

Acked-by: Rik van Riel<riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
