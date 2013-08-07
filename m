Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 1614C6B006C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 03:04:06 -0400 (EDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MR500IZ3FMB2D30@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 07 Aug 2013 08:04:04 +0100 (BST)
Message-id: <1375859042.17079.1.camel@AMDC1943>
Subject: Re: [RFC PATCH 3/4] mm: add zbud flag to page flags
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Wed, 07 Aug 2013 09:04:02 +0200
In-reply-to: <52012B35.90801@intel.com>
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
 <1375771361-8388-4-git-send-email-k.kozlowski@samsung.com>
 <52012B35.90801@intel.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On wto, 2013-08-06 at 09:58 -0700, Dave Hansen wrote:
> On 08/05/2013 11:42 PM, Krzysztof Kozlowski wrote:
> > +#ifdef CONFIG_ZBUD
> > +	/* Allocated by zbud. Flag is necessary to find zbud pages to unuse
> > +	 * during migration/compaction.
> > +	 */
> > +	PG_zbud,
> > +#endif
> 
> Do you _really_ need an absolutely new, unshared page flag?
> The zbud code doesn't really look like it uses any of the space in
> 'struct page'.
> 
> I think you could pretty easily alias PG_zbud=PG_slab, then use the
> page->{private,slab_cache} (or some other unused field) in 'struct page'
> to store a cookie to differentiate slab and zbud pages.

Thanks for idea, I will try that.

Best regards,
Krzysztof


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
