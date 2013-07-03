Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 490716B0033
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:56:04 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c13so140351eek.17
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 07:56:02 -0700 (PDT)
Date: Wed, 3 Jul 2013 15:55:56 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH 1/2] hugetlb: properly account rss
Message-ID: <20130703145555.GA7449@linaro.org>
References: <1371581225-27535-1-git-send-email-joern@logfs.org>
 <1371581225-27535-2-git-send-email-joern@logfs.org>
 <20130703134118.GA4978@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130703134118.GA4978@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joern Engel <joern@logfs.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jul 03, 2013 at 02:41:19PM +0100, Steve Capper wrote:

[ ... ]

> Excluding VM_SHARED VMAs from the counter increment/decrement stopped the
> warnings for me.

Whoops sorry, the fork copy on write test flagged a BUG, hugetlb_cow will need
to be examined too.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
