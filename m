Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1829F83090
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 09:41:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g202so115426262pfb.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 06:41:16 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id hl7si4261292pad.42.2016.09.08.06.41.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 06:41:15 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id D763520374
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 13:41:13 +0000 (UTC)
Received: from mail-yb0-f177.google.com (mail-yb0-f177.google.com [209.85.213.177])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8F2542034C
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 13:41:12 +0000 (UTC)
Received: by mail-yb0-f177.google.com with SMTP id x93so16896985ybh.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 06:41:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1472712907-12700-4-git-send-email-thunder.leizhen@huawei.com>
References: <1472712907-12700-1-git-send-email-thunder.leizhen@huawei.com> <1472712907-12700-4-git-send-email-thunder.leizhen@huawei.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Thu, 8 Sep 2016 08:40:51 -0500
Message-ID: <CAL_JsqK6P86F=AJjC2J6W4NOFXavb4e-OR_dmc4iofUNCJGrJA@mail.gmail.com>
Subject: Re: [PATCH v8 03/16] of/numa: add nid check for memory block
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhen Lei <thunder.leizhen@huawei.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, Frank Rowand <frowand.list@gmail.com>, devicetree <devicetree@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Thu, Sep 1, 2016 at 1:54 AM, Zhen Lei <thunder.leizhen@huawei.com> wrote:
> If the numa-id which was configured in memory@ devicetree node is greater
> than MAX_NUMNODES, we should report a warning. We have done this for cpus
> and distance-map dt nodes, this patch help them to be consistent.
>
> Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
> ---
>  drivers/of/of_numa.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/drivers/of/of_numa.c b/drivers/of/of_numa.c
> index 7b3fbdc..c1bd62c 100644
> --- a/drivers/of/of_numa.c
> +++ b/drivers/of/of_numa.c
> @@ -75,6 +75,11 @@ static int __init of_numa_parse_memory_nodes(void)
>                          */
>                         continue;
>
> +               if (nid >= MAX_NUMNODES) {
> +                       pr_warn("NUMA: Node id %u exceeds maximum value\n", nid);

Really using pr_fmt should come first so you're not changing this
line. But not worth respinning for that:

Acked-by: Rob Herring <robh@kernel.org>

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
