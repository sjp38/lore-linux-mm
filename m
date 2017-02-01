Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5147F6B0038
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 20:05:36 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f144so541227412pfa.3
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 17:05:36 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id h7si17579650plk.119.2017.01.31.17.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 31 Jan 2017 17:05:35 -0800 (PST)
In-Reply-To: <1479314703-18989-1-git-send-email-arbab@linux.vnet.ibm.com>
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: powerpc/mm: allow memory hotplug into an offline node
Message-Id: <3vClL33fB1z9t9b@ozlabs.org>
Date: Wed,  1 Feb 2017 12:05:31 +1100 (AEDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, John Allen <jallen@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, Nathan Fontenot <nfont@linux.vnet.ibm.com>

On Wed, 2016-11-16 at 16:45:03 UTC, Reza Arbab wrote:
> Relax the check preventing us from hotplugging into an offline node.
> 
> This limitation was added in commit 482ec7c403d2 ("[PATCH] powerpc numa:
> Support sparse online node map") to prevent adding resources to an
> uninitialized node.
> 
> These days, there is no harm in doing so. The addition will actually
> cause the node to be initialized and onlined; add_memory_resource()
> calls hotadd_new_pgdat() (if necessary) and node_set_online().
> 
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>
> Cc: John Allen <jallen@linux.vnet.ibm.com>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>

Applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/2a8628d41602dc9f988af051a657ee

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
