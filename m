Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 10E0D5F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 05:14:28 -0400 (EDT)
Date: Mon, 6 Apr 2009 13:13:48 +0400
From: Andrey Panin <pazke@donpac.ru>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-ID: <20090406091348.GA18464@ports.donpac.ru>
References: <1238855722-32606-1-git-send-email-ieidus@redhat.com> <1238855722-32606-2-git-send-email-ieidus@redhat.com> <1238855722-32606-3-git-send-email-ieidus@redhat.com> <1238855722-32606-4-git-send-email-ieidus@redhat.com> <1238855722-32606-5-git-send-email-ieidus@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1238855722-32606-5-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On 094, 04 04, 2009 at 05:35:22PM +0300, Izik Eidus wrote:

<SNIP>

> +static inline u32 calc_checksum(struct page *page)
> +{
> +	u32 checksum;
> +	void *addr = kmap_atomic(page, KM_USER0);
> +	checksum = jhash(addr, PAGE_SIZE, 17);

Why jhash2() is not used here ? It's faster and leads to smaller code size.

> +	kunmap_atomic(addr, KM_USER0);
> +	return checksum;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
