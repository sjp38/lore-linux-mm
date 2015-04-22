Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC6F6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 19:45:03 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so1943922pdb.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 16:45:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id vs8si9860800pab.72.2015.04.22.16.45.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 16:45:02 -0700 (PDT)
Date: Wed, 22 Apr 2015 16:45:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/13] x86: mm: Enable deferred struct page
 initialisation on x86-64
Message-Id: <20150422164500.121a355e6b578243cb3650e3@linux-foundation.org>
In-Reply-To: <1429722473-28118-11-git-send-email-mgorman@suse.de>
References: <1429722473-28118-1-git-send-email-mgorman@suse.de>
	<1429722473-28118-11-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, 22 Apr 2015 18:07:50 +0100 Mel Gorman <mgorman@suse.de> wrote:

> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -32,6 +32,7 @@ config X86
>  	select HAVE_UNSTABLE_SCHED_CLOCK
>  	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
>  	select ARCH_SUPPORTS_INT128 if X86_64
> +	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT if X86_64 && NUMA

Put this in the "config X86_64" section and skip the "X86_64 &&"?

Can we omit the whole defer_meminit= thing and permanently enable the
feature?  That's simpler, provides better test coverage and is, we
hope, faster.

And can this be used on non-NUMA?  Presumably that won't speed things
up any if we're bandwidth limited but again it's simpler and provides
better coverage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
