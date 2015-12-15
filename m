Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id DEF136B0254
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 19:20:06 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id to4so18366949igc.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 16:20:06 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id s9si500488igg.47.2015.12.14.16.20.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Dec 2015 16:20:06 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NZD00AG1I9E7U90@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 15 Dec 2015 00:20:02 +0000 (GMT)
Subject: Re: [PATCH 10/11] arm/samsung: Change s3c_pm_run_res() to use System
 RAM type
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
 <1450136246-17053-10-git-send-email-toshi.kani@hpe.com>
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Message-id: <566F5CAE.5020004@samsung.com>
Date: Tue, 15 Dec 2015 09:19:58 +0900
MIME-version: 1.0
In-reply-to: <1450136246-17053-10-git-send-email-toshi.kani@hpe.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>, akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kukjin Kim <kgene@kernel.org>, linux-samsung-soc@vger.kernel.org

On 15.12.2015 08:37, Toshi Kani wrote:
> Change s3c_pm_run_res() to check with IORESOURCE_SYSTEM_RAM,
> instead of strcmp() with "System RAM", in the resource table.
> 
> No functional change is made to the interface.
> 
> Cc: Kukjin Kim <kgene@kernel.org>
> Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> Cc: linux-samsung-soc@vger.kernel.org
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> ---
>  arch/arm/plat-samsung/pm-check.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Reviewed-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Best regards,
Krzysztof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
