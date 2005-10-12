Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9CBvX5p022984
	for <linux-mm@kvack.org>; Wed, 12 Oct 2005 07:57:33 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9CBvXhU058220
	for <linux-mm@kvack.org>; Wed, 12 Oct 2005 07:57:33 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9CBvWnS030280
	for <linux-mm@kvack.org>; Wed, 12 Oct 2005 07:57:33 -0400
Subject: Re: [Lhms-devel] [PATCH 8/8] Fragmentation Avoidance V17: 008_stats
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051011151302.16178.46089.sendpatchset@skynet.csn.ul.ie>
References: <20051011151221.16178.67130.sendpatchset@skynet.csn.ul.ie>
	 <20051011151302.16178.46089.sendpatchset@skynet.csn.ul.ie>
Content-Type: text/plain
Date: Wed, 12 Oct 2005 04:57:27 -0700
Message-Id: <1129118247.6134.54.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@osdl.org>, jschopp@austin.ibm.com, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-10-11 at 16:13 +0100, Mel Gorman wrote:
> +#ifdef CONFIG_ALLOCSTAT
> +               memset((unsigned long *)zone->fallback_count, 0,
> +                               sizeof(zone->fallback_count));
> +               memset((unsigned long *)zone->alloc_count, 0,
> +                               sizeof(zone->alloc_count));
> +               memset((unsigned long *)zone->alloc_count, 0,
> +                               sizeof(zone->alloc_count));
> +               zone->kernnorclm_partial_steal=0;
> +               zone->kernnorclm_full_steal=0;
> +               zone->reserve_count[RCLM_NORCLM] =
> +                               realsize >> (MAX_ORDER-1);
> +#endif

The struct zone is part of the pgdat which is zeroed at boot-time on all
architectures and configuration that I have ever audited.  Re-zeroing
parts of it here is unnecessary.

BTW, that '=0' with no spaces is anti-CodingStyle.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
