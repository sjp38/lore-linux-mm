Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B40556B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 12:59:12 -0400 (EDT)
Message-ID: <52012B35.90801@intel.com>
Date: Tue, 06 Aug 2013 09:58:29 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/4] mm: add zbud flag to page flags
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com> <1375771361-8388-4-git-send-email-k.kozlowski@samsung.com>
In-Reply-To: <1375771361-8388-4-git-send-email-k.kozlowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On 08/05/2013 11:42 PM, Krzysztof Kozlowski wrote:
> +#ifdef CONFIG_ZBUD
> +	/* Allocated by zbud. Flag is necessary to find zbud pages to unuse
> +	 * during migration/compaction.
> +	 */
> +	PG_zbud,
> +#endif

Do you _really_ need an absolutely new, unshared page flag?
The zbud code doesn't really look like it uses any of the space in
'struct page'.

I think you could pretty easily alias PG_zbud=PG_slab, then use the
page->{private,slab_cache} (or some other unused field) in 'struct page'
to store a cookie to differentiate slab and zbud pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
