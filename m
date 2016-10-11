Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D17B6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 09:59:08 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ry6so15641458pac.1
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 06:59:08 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id bz1si3578014pab.49.2016.10.11.06.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 06:59:07 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 7564E2037C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 13:59:06 +0000 (UTC)
Received: from mail-yw0-f178.google.com (mail-yw0-f178.google.com [209.85.161.178])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 79B3F20351
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 13:59:04 +0000 (UTC)
Received: by mail-yw0-f178.google.com with SMTP id t192so13083957ywf.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 06:59:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1475778995-1420-3-git-send-email-arbab@linux.vnet.ibm.com>
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com> <1475778995-1420-3-git-send-email-arbab@linux.vnet.ibm.com>
From: Rob Herring <robh+dt@kernel.org>
Date: Tue, 11 Oct 2016 08:58:43 -0500
Message-ID: <CAL_JsqJmqaH8p2fUyZN8EdHNfshfdyUHKsaT8JN_G1AQuua_Qg@mail.gmail.com>
Subject: Re: [PATCH v4 2/5] drivers/of: do not add memory for unavailable nodes
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Oct 6, 2016 at 1:36 PM, Reza Arbab <arbab@linux.vnet.ibm.com> wrote:
> Respect the standard dt "status" property when scanning memory nodes in
> early_init_dt_scan_memory(), so that if the node is unavailable, no
> memory will be added.
>
> The use case at hand is accelerator or device memory, which may be
> unusable until post-boot initialization of the memory link. Such a node
> can be described in the dt as any other, given its status is "disabled".
> Per the device tree specification,
>
> "disabled"
>         Indicates that the device is not presently operational, but it
>         might become operational in the future (for example, something
>         is not plugged in, or switched off).
>
> Once such memory is made operational, it can then be hotplugged.
>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  drivers/of/fdt.c | 3 +++
>  1 file changed, 3 insertions(+)

Acked-by: Rob Herring <robh@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
