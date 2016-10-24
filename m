Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 879A16B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 06:24:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n18so12511260pfe.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 03:24:13 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 145si14655967pgc.315.2016.10.24.03.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 03:24:12 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v4 2/5] drivers/of: do not add memory for unavailable nodes
In-Reply-To: <2344394.NlaWgtFOqB@new-mexico>
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com> <1475778995-1420-3-git-send-email-arbab@linux.vnet.ibm.com> <2344394.NlaWgtFOqB@new-mexico>
Date: Mon, 24 Oct 2016 21:24:04 +1100
Message-ID: <87vawixcxn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alistair Popple <apopple@au1.ibm.com>, linuxppc-dev@lists.ozlabs.org
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Stewart Smith <stewart@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>

Alistair Popple <apopple@au1.ibm.com> writes:

> Hi Reza,
>
> On Thu, 6 Oct 2016 01:36:32 PM Reza Arbab wrote:
>> Respect the standard dt "status" property when scanning memory nodes in
>> early_init_dt_scan_memory(), so that if the node is unavailable, no
>> memory will be added.
>
> What happens if a kernel without this patch is booted on a system with some 
> status="disabled" device-nodes? Do older kernels just ignore this memory or do 
> they try to use it?
>
> From what I can tell it seems that kernels without this patch will try and use 
> this memory even if it is marked in the device-tree as status="disabled" which 
> could lead to problems for older kernels when we start exporting this property 
> from firmware.

The code already looks for "linux,usable-memory" in preference to "reg".
Can you use that instead?

That would have the advantage that existing kernels already understand
it.

Another problem with using "status" is we could have device trees out
there that have status = disabled and we don't know about it, and by
changing the kernel to use that property we break people's systems.
Though for memory nodes my guess is that's not true, but you never know ...

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
