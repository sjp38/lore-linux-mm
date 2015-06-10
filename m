Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 683596B006E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 03:50:40 -0400 (EDT)
Received: by lbbtu8 with SMTP id tu8so23633034lbb.2
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:50:39 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id gb5si16247739wjb.21.2015.06.10.00.50.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 00:50:38 -0700 (PDT)
Received: by wibdq8 with SMTP id dq8so38245325wib.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:50:38 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:50:34 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/4] mm: Defer flush of writable TLB entries
Message-ID: <20150610075033.GB18049@gmail.com>
References: <1433871118-15207-1-git-send-email-mgorman@suse.de>
 <1433871118-15207-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433871118-15207-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> +
> +	/*
> +	 * If the PTE was dirty then it's best to assume it's writable. The
> +	 * caller must use try_to_unmap_flush_dirty() or try_to_unmap_flush()
> +	 * before the page any IO is initiated.
> +	 */

Speling nit: "before the page any IO is initiated" does not parse for me.

> +			/*
> +			 * Page is dirty. Flush the TLB if a writable entry
> +			 * potentially exists to avoid CPU writes after IO
> +			 * starts and then write it out here
> +			 */

s/here/here.

or:

s/here/here:

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
