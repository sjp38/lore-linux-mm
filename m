Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9246B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 11:29:11 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fi2so345833551pad.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 08:29:11 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id h189si37345806pfb.251.2016.10.03.08.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 08:29:09 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id A1FB220251
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 15:29:08 +0000 (UTC)
Received: from mail-yw0-f174.google.com (mail-yw0-f174.google.com [209.85.161.174])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9CB4320254
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 15:29:06 +0000 (UTC)
Received: by mail-yw0-f174.google.com with SMTP id t193so30875268ywc.2
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 08:29:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1474828616-16608-2-git-send-email-arbab@linux.vnet.ibm.com>
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com> <1474828616-16608-2-git-send-email-arbab@linux.vnet.ibm.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Mon, 3 Oct 2016 10:28:45 -0500
Message-ID: <CAL_JsqKkYFeENE226QFsoqEMJEPpXET0-xJOWoA0j_tbOPu0_g@mail.gmail.com>
Subject: Re: [PATCH v3 1/5] drivers/of: introduce of_fdt_is_available()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Sep 25, 2016 at 1:36 PM, Reza Arbab <arbab@linux.vnet.ibm.com> wrote:
> In __fdt_scan_reserved_mem(), the availability of a node is determined
> by testing its "status" property.
>
> Move this check into its own function, borrowing logic from the
> unflattened version, of_device_is_available().
>
> Another caller will be added in a subsequent patch.
>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  drivers/of/fdt.c       | 26 +++++++++++++++++++++++---
>  include/linux/of_fdt.h |  2 ++
>  2 files changed, 25 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index 085c638..9241c6e 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -151,6 +151,23 @@ int of_fdt_match(const void *blob, unsigned long node,
>         return score;
>  }
>
> +bool of_fdt_is_available(const void *blob, unsigned long node)

of_fdt_device_is_available

[...]

> +bool __init of_flat_dt_is_available(unsigned long node)

And of_flat_dt_device_is_available

With that,

Acked-by: Rob Herring <robh@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
