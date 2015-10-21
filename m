Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A257782F66
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:18:48 -0400 (EDT)
Received: by pasz6 with SMTP id z6so63914159pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:18:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ax2si15615004pbc.170.2015.10.21.13.18.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:18:48 -0700 (PDT)
Subject: Re: [PATCH v11 05/15] HMM: introduce heterogeneous memory management
 v5.
References: <1445461210-2605-1-git-send-email-jglisse@redhat.com>
 <1445461210-2605-6-git-send-email-jglisse@redhat.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <5627F31B.8060502@infradead.org>
Date: Wed, 21 Oct 2015 13:18:35 -0700
MIME-Version: 1.0
In-Reply-To: <1445461210-2605-6-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Jatin Kumar <jakumar@nvidia.com>

On 10/21/15 14:00, Jerome Glisse wrote:

> diff --git a/mm/Kconfig b/mm/Kconfig
> index 0d9fdcd..10ed2de 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -680,3 +680,15 @@ config ZONE_DEVICE
>  
>  config FRAME_VECTOR
>  	bool
> +
> +config HMM
> +	bool "Enable heterogeneous memory management (HMM)"
> +	depends on MMU
> +	select MMU_NOTIFIER
> +	default n
> +	help
> +	  Heterogeneous memory management provide infrastructure for a device

	                                  provides

> +	  to mirror a process address space into an hardware mmu or into any

	                                    into a hardware MMU

> +	  things supporting pagefault like event.
> +
> +	  If unsure, say N to disable hmm.

	                              HMM.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
