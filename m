Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BA1CA6B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 20:40:58 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id b13so1469132pat.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 17:40:58 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id pj9si3491338pac.4.2016.06.20.17.40.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 17:40:57 -0700 (PDT)
In-Reply-To: <1462958539-25552-1-git-send-email-oohall@gmail.com>
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [v2] powerpc/mm: Ensure "special" zones are empty
Message-Id: <3rYTRT6gDSz9t0f@ozlabs.org>
Date: Tue, 21 Jun 2016 10:40:53 +1000 (AEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>, linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org

On Wed, 2016-11-05 at 09:22:18 UTC, Oliver O'Halloran wrote:
> The mm zone mechanism was traditionally used by arch specific code to
> partition memory into allocation zones. However there are several zones
> that are managed by the mm subsystem rather than the architecture. Most
> architectures set the max PFN of these special zones to zero, however on
> powerpc we set them to ~0ul. This, in conjunction with a bug in
> free_area_init_nodes() results in all of system memory being placed in
> ZONE_DEVICE when enabled. Device memory cannot be used for regular kernel
> memory allocations so this will cause a kernel panic at boot. Given the
> planned addition of more mm managed zones (ZONE_CMA) we should aim to be
> consistent with every other architecture and set the max PFN for these
> zones to zero.
> 
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
> Reviewed-by: Balbir Singh <bsingharora@gmail.com>
> Cc: linux-mm@kvack.org

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/3079abe555511031e2ba5d1e21

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
