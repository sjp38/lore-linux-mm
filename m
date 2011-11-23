Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4016D6B00CF
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 14:07:25 -0500 (EST)
Received: by iaek3 with SMTP id k3so2608514iae.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 11:07:22 -0800 (PST)
Date: Wed, 23 Nov 2011 11:07:05 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
In-Reply-To: <1322038412-29013-1-git-send-email-amwang@redhat.com>
Message-ID: <alpine.LSU.2.00.1111231100110.2226@sister.anvils>
References: <1322038412-29013-1-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 23 Nov 2011, Cong Wang wrote:
> +
> +	while (index < end) {
> +		ret = shmem_getpage(inode, index, &page, SGP_WRITE, NULL);
> +		if (ret) {
> +			if (ret == -ENOSPC)
> +				goto undo;
...
> +undo:
> +	while (index > start) {
> +		shmem_truncate_page(inode, index);
> +		index--;
> +	}

As I said before, I won't actually be reviewing and testing this for
a week or two; but before this goes any further, must point out how
wrong it is.  Here you'll be deleting any pages in the range that were
already present before the failing fallocate().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
