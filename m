Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id AC3526B0070
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 18:43:52 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so143915807pac.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:43:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m4si31783770pdp.192.2015.04.27.15.43.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 15:43:52 -0700 (PDT)
Date: Mon, 27 Apr 2015 15:43:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 08/13] mm: meminit: Initialise remaining struct pages in
 parallel with kswapd
Message-Id: <20150427154350.4d649694a56e5bbc519e1fb4@linux-foundation.org>
In-Reply-To: <1429785196-7668-9-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
	<1429785196-7668-9-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 23 Apr 2015 11:33:11 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Only a subset of struct pages are initialised at the moment. When this patch
> is applied kswapd initialise the remaining struct pages in parallel. This
> should boot faster by spreading the work to multiple CPUs and initialising
> data that is local to the CPU.  The user-visible effect on large machines
> is that free memory will appear to rapidly increase early in the lifetime
> of the system until kswapd reports that all memory is initialised in the
> kernel log.  Once initialised there should be no other user-visibile effects.
> 
> ...
>
> +	pr_info("kswapd %d initialised deferred memory in %ums\n", nid,
> +					jiffies_to_msecs(jiffies - start));

It might be nice to tell people how much deferred memory kswapd
initialised.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
