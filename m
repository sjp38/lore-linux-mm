Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id F0D266B00B3
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 04:15:50 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so4912676wiv.5
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 01:15:50 -0800 (PST)
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com. [74.125.82.179])
        by mx.google.com with ESMTPS id w7si22800424wiz.10.2015.01.06.01.15.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 01:15:50 -0800 (PST)
Received: by mail-we0-f179.google.com with SMTP id q59so9249868wes.38
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 01:15:50 -0800 (PST)
Date: Tue, 6 Jan 2015 09:15:48 +0000
From: Matt Fleming <matt@console-pimps.org>
Subject: Re: [PATCH 3/8] memblock: add physmem to memblock_dump_all() output
Message-ID: <20150106091548.GH3163@console-pimps.org>
References: <1419275322-29811-1-git-send-email-ard.biesheuvel@linaro.org>
 <1419275322-29811-4-git-send-email-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419275322-29811-4-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, roy.franz@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com, matt.fleming@intel.com, bp@alien8.de, dyoung@redhat.com, msalter@redhat.com, grant.likely@linaro.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(Adding Andrew, linux-mm and lkml)

On Mon, 22 Dec, at 07:08:37PM, Ard Biesheuvel wrote:
> If CONFIG_HAVE_MEMBLOCK_PHYS_MAP is set, there is a third memblock
> map called 'physmem'. Add it to the output of memblock_dump_all().
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> ---
>  mm/memblock.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 252b77bdf65e..c27353beb260 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1522,6 +1522,9 @@ void __init_memblock __memblock_dump_all(void)
>  
>  	memblock_dump(&memblock.memory, "memory");
>  	memblock_dump(&memblock.reserved, "reserved");
> +#ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> +	memblock_dump(&memblock.physmem, "physmem");
> +#endif
>  }
>  
>  void __init memblock_allow_resize(void)
> -- 
> 1.8.3.2
> 

-- 
Matt Fleming, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
