Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAFD16B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 07:45:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x17-v6so10123448pfm.18
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 04:45:35 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id u13-v6si14636193pgq.585.2018.06.19.04.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jun 2018 04:45:34 -0700 (PDT)
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
	by mailout1.w1.samsung.com (KnoxPortal) with ESMTP id 20180619114528euoutp01413229bbb05c022854f68a09f158d467~5jSLDENz60897908979euoutp010
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 11:45:28 +0000 (GMT)
Subject: Re: dynamic reservation and allocation of physically contiguous
 memory using CMA
From: Marek Szyprowski <m.szyprowski@samsung.com>
Date: Tue, 19 Jun 2018 13:45:26 +0200
MIME-Version: 1.0
In-Reply-To: <DF0025E0-5C00-4566-82D2-F3599F206210@cisco.com>
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Message-Id: <20180619114527eucas1p154dc59055086a514a0423fc4cfb0b8c8~5jSJigH_r0719907199eucas1p1N@eucas1p1.samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20180618182314epcas1p37a2b1ba6db9a829c07abf55ca0d3d50d@epcas1p3.samsung.com>
	<DF0025E0-5C00-4566-82D2-F3599F206210@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Amit Chandra (amichand)" <amichand@cisco.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Amit,

On 2018-06-18 20:23, Amit Chandra (amichand) wrote:
>
> Hi experts,
>
> I had a question related to CMA. I have been trying to use the CMA 
> infra to reserve and allocate physically contiguous memory dynamically 
> at runtime.
>
> I built a custom kernel based on linux-4.14.47 to invoke the cma 
> initialization apis at runtime from kernel loadable module.
>
> I invoke cma_declare_contiguous() followed by cma_init_reserved_areas().
>
> cma_declare_contiguous throws no surprises and succeeds. The issue 
> happens when cma_init_reserved_areas() is invoked post that.
>
> Here is the kernel log snippet post that call:
>
> Jun 15 03:30:31 ubuntu-quickstart kernel: [A  384.593218] cma: 
> cma_declare_contiguous(size 0x0000000200000000, base 
> 0x0000000000000000, limit 0x0000000000000000 alignment 0x0000000000000000)
>
> Jun 15 03:30:31 ubuntu-quickstart kernel: [A  384.593228] cma: Reserved 
> 8192 MiB at 0x0000001d4d000000
>
> Jun 15 03:30:31 ubuntu-quickstart kernel: [A  384.593345] BUG: Bad page 
> state in process insmodA  pfn:1d4d000
>
> Jun 15 03:30:31 ubuntu-quickstart kernel: [A  384.595758] 
> page:ffffefc335340000 count:0 mapcount:-127 mapping:A A A A A A A A A  (null) 
> index:0x0
>
> Jun 15 03:30:31 ubuntu-quickstart kernel: [A  384.599193] flags: 
> 0x57fffc000000000()
>
> Jun 15 03:30:31 ubuntu-quickstart kernel: [A  384.600751] raw: 
> 057fffc000000000 0000000000000000 0000000000000000 00000000ffffff80
>
> Jun 15 03:30:31 ubuntu-quickstart kernel: [A  384.603946] raw: 
> ffffefc335330020 ffffefc335350020 000000000000000a 0000000000000000
>
> Jun 15 03:30:31 ubuntu-quickstart kernel: [A  384.607152] page dumped 
> because: nonzero mapcount
>
> I am having a hard time trying to understand why the mapcount is less 
> than 0 here. I figured this is happening in the call to __free_pages() 
> from init_cma_reserved_pageblock().
>
> Any pointers here would be really helpful. If I am missing any step 
> for cma reservation, please do let me know.
>
> Thanks in advance.
>

CMA initialization is possible only on very early boot stage. CMA will 
not work as dynamic module.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
