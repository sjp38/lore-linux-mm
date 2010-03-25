Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 840676B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 04:39:53 -0400 (EDT)
Received: by wwa36 with SMTP id 36so202686wwa.14
        for <linux-mm@kvack.org>; Thu, 25 Mar 2010 01:39:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1269417391.8599.188.camel@pasglop>
References: <1269417391.8599.188.camel@pasglop>
Date: Thu, 25 Mar 2010 14:09:49 +0530
Message-ID: <62fe9ccc1003250139m7e8fecf9g2976a1bc244f6aa5@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/vmalloc: Export purge_vmap_area_lazy()
From: MJ embd <mj.embd@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 1:26 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> Some powerpc code needs to ensure that all previous iounmap/vunmap has
> really been flushed out of the MMU hash table. Without that, various
> hotplug operations may fail when trying to return those pieces to
> the hypervisor due to existing active mappings.
Are you talking about KVM or any other hypervisor ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
