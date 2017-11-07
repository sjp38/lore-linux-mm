Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7877D680F85
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 11:21:28 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a8so14848129pfc.6
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 08:21:28 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10121.outbound.protection.outlook.com. [40.107.1.121])
        by mx.google.com with ESMTPS id z3si1532726pln.252.2017.11.07.08.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Nov 2017 08:21:26 -0800 (PST)
Subject: Re: [PATCH v2 2/2] arm64/mm/kasan: don't use vmemmap_populate() to
 initialize shadow
References: <20171106183516.6644-1-pasha.tatashin@oracle.com>
 <20171106183516.6644-3-pasha.tatashin@oracle.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a1f63638-7edd-a498-d89f-67dea59a247a@virtuozzo.com>
Date: Tue, 7 Nov 2017 19:24:38 +0300
MIME-Version: 1.0
In-Reply-To: <20171106183516.6644-3-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, will.deacon@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On 11/06/2017 09:35 PM, Pavel Tatashin wrote:
> From: Will Deacon <will.deacon@arm.com>
> 
> The kasan shadow is currently mapped using vmemmap_populate() since that
> provides a semi-convenient way to map pages into init_top_pgt. However,
> since that no longer zeroes the mapped pages, it is not suitable for kasan,
> which requires zeroed shadow memory.
> 
> Add kasan_populate_shadow() interface and use it instead of
> vmemmap_populate(). Besides, this allows us to take advantage of gigantic
> pages and use them to populate the shadow, which should save us some memory
> wasted on page tables and reduce TLB pressure.
> 
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
