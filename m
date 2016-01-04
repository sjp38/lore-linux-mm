Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5077F6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 06:41:35 -0500 (EST)
Received: by mail-qg0-f47.google.com with SMTP id b35so121765303qge.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 03:41:35 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id o97si29166332qgd.69.2016.01.04.03.41.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 03:41:34 -0800 (PST)
Message-ID: <568A5A6B.3030700@citrix.com>
Date: Mon, 4 Jan 2016 11:41:31 +0000
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCH v2 08/16] xen, mm: Set IORESOURCE_SYSTEM_RAM
 to System RAM
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
 <1451081365-15190-8-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1451081365-15190-8-git-send-email-toshi.kani@hpe.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>, akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org

On 25/12/15 22:09, Toshi Kani wrote:
> Set IORESOURCE_SYSTEM_RAM to 'flags' of struct resource entries
> with "System RAM".
[...]
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -257,7 +257,7 @@ static struct resource *additional_memory_resource(phys_addr_t size)
>  		return NULL;
>  
>  	res->name = "System RAM";
> -	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
>  
>  	ret = allocate_resource(&iomem_resource, res,
>  				size, 0, -1,

Acked-by: David Vrabel <david.vrabel@citrix.com>

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
