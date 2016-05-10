Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9866B0005
	for <linux-mm@kvack.org>; Tue, 10 May 2016 17:48:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so48407176pfz.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 14:48:41 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 21si4953843pfi.15.2016.05.10.14.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 14:48:40 -0700 (PDT)
In-Reply-To: <1462434849-14935-1-git-send-email-oohall@gmail.com>
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [v2,1/2] powerpc/mm: define TOP_ZONE as a constant
Message-Id: <3r4CYd1QC5z9t47@ozlabs.org>
Date: Wed, 11 May 2016 07:48:37 +1000 (AEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>, linuxppc-dev@lists.ozlabs.org
Cc: linux-mm@kvack.org

On Thu, 2016-05-05 at 07:54:08 UTC, Oliver O'Halloran wrote:
> The zone that contains the top of memory will be either ZONE_NORMAL
> or ZONE_HIGHMEM depending on the kernel config. There are two functions
> that require this information and both of them use an #ifdef to set
> a local variable (top_zone). This is a little silly so lets just make it
> a constant.
> 
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
> Cc: linux-mm@kvack.org

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/d69777dbefd707974aed91918d

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
