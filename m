Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C66576B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 04:09:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p96so3139017wrb.12
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 01:09:46 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.20])
        by mx.google.com with ESMTPS id r19si7009044wrb.276.2017.10.24.01.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 01:09:45 -0700 (PDT)
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
References: <93684e4b-9e60-ef3a-ba62-5719fdf7cff9@gmx.de>
 <6b639da5-ad9a-158c-ad4a-7a4e44bd98fc@gmx.de>
 <5fb8955d-23af-ec85-a19f-3a5b26cc04d1@oracle.com>
 <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
 <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
 <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
 <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
 <20171023165717.qx5qluryshz62zv5@dhcp22.suse.cz>
 <b138bcf8-0a66-a988-4040-520d767da266@gmx.de>
 <4d855be6-7718-f428-91d6-d0c6b44b7ff4@oracle.com>
From: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Message-ID: <64606243-e770-f5f6-e9dc-6495ce1cb0bd@gmx.de>
Date: Tue, 24 Oct 2017 10:09:19 +0200
MIME-Version: 1.0
In-Reply-To: <4d855be6-7718-f428-91d6-d0c6b44b7ff4@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 2017-10-23 20:51, Mike Kravetz wrote:
 > [...]
> Well at least this has a built in fall back mechanism.  When using hugetlb(fs)
> pages, you would need to handle the case where mremap fails due to lack of
> configured huge pages.

You're missing the point. I never asked for a fall-back mechanism, even 
though it certainly has its use cases. It just isn't mine. In such a 
situation it wouldn't be hard to detect if the user requested huger 
pages, and then fall back to a smaller size. The only difference is that 
I'd have to implement it myself.

But all of that does not change the fact that it's not transparent.

> I assume your allocator will be for somewhat general application usage.

Define "general purpose" first. The allocator itself isn't transparent 
to typical malloc/realloc/free-based approaches, and it isn't so very 
deliberately.

> Yet,
> for the most reliability the user/admin will need to know at boot time how
> many huge pages will be needed and set that up.
That's what I'm trying to argue. With how much memory were typical 386s 
equipped back then? 16 MiBs? With a page size of 4 KiBs that leaves 4096 
pages to map the entirety of RAM.

My current testing box has 8 GiBs. If I were to map the entirety of my 
RAM with 2-MiB pages that would still require 4096 pages. Did anyone set 
up pages pools with Linux in the 90s? Did anyone complain that 4096 
bytes are too much of a page size to effectively use memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
