Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id C208F6B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:12:35 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id l127so75951588iof.3
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 20:12:35 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id g101si7558843ioi.116.2016.02.24.20.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 20:12:33 -0800 (PST)
Message-ID: <1456373550.30375.3.camel@ellerman.id.au>
Subject: Re: Problems with swapping in v4.5-rc on POWER
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Thu, 25 Feb 2016 15:12:30 +1100
In-Reply-To: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils>
References: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Wed, 2016-02-24 at 18:10 -0800, Hugh Dickins via Linuxppc-dev wrote:

> I've plagiarized the subject from Paulus's "Problems with THP" mail
> last weekend; but my similar problems are on PowerMac G5 baremetal,
> with 4kB pages, not capable of THP and no THP configured in.
> 
> Under heavily swapping load, running kernel builds on tmpfs in limited
> memory, I've been seeing random segfaults too, internal compiler errors
> etc.  Not easily reproduced: sometimes happens in minutes, sometimes
> not for several hours.
> 
> I tried and failed to construct a reproducer for you: my lack of a good
> recipe has deterred me from reporting it, and seeing Paulus's mail on
> THP gave me hope that the answer would come up in that thread; but no,
> that was quickly resolved as a THP issue, since fixed.
> 
> (Mine had appeared to be fixed in v4.5-rc4 anyway; but I guess I
> just didn't try hard enough, it resurfaced on -rc5 immediately.)
> 
> I've seen no sign of such problems on x86.  And I saw no sign of such
> problems on v4.4-rc8-mm1, when I included the fixes to the _PAGE_PTE
> and _PAGE_SWP_SOFT_DIRTY swapoff issues we discussed back then (in
> 33 hours of load, should be good enough; but did see such problems
> a couple of times before including those fixes - I took them to be
> a side-effect of the page flags issue, but now rather doubt that).
> 
> The minutes or hours thing: I wonder if that indicates a missing
> initialization somewhere: that can easily show up soon after booting,
> but then the machine settles into a steady state of reusing the same
> structures, now initialized; until much later something disturbs the
> state and it has to allocate more.  Sheer speculation, but I wonder.

Thanks Hugh.

I do run tests on G5, but obviously not rigorously enough. I kicked off a few
kernel builds on mine and it survived, though once it hits swap it's almost
unusably slow. I'll leave it running overnight and see if I hit anything.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
