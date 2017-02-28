Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 779C06B039F
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:27:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p185so12900046pfb.4
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 04:27:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f20si1636498pfe.205.2017.02.28.04.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 04:27:07 -0800 (PST)
Date: Tue, 28 Feb 2017 13:26:54 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228122654.GF5680@worktop>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> +	/*
> +	 * Each work of workqueue might run in a different context,
> +	 * thanks to concurrency support of workqueue. So we have to
> +	 * distinguish each work to avoid false positive.
> +	 *
> +	 * TODO: We can also add dependencies between two acquisitions
> +	 * of different work_id, if they don't cause a sleep so make
> +	 * the worker stalled.
> +	 */
> +	unsigned int		work_id;

I don't understand... please explain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
