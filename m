Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 95AF06B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 14:58:00 -0400 (EDT)
Date: Tue, 6 Aug 2013 13:57:59 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 3/4] mm: add zbud flag to page flags
Message-ID: <20130806185759.GE5765@medulla.variantweb.net>
References: <1375771361-8388-1-git-send-email-k.kozlowski@samsung.com>
 <1375771361-8388-4-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375771361-8388-4-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Tue, Aug 06, 2013 at 08:42:40AM +0200, Krzysztof Kozlowski wrote:
> Add PageZbud flag to page flags to distinguish pages allocated in zbud.
> Currently these pages do not have any flags set.

Yeah, using a page flags for zbud is probably not going to be
acceptable.  We'll have to find some other way to identify zbud pages.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
