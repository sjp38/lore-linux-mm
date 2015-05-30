Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 131186B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 16:53:02 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so40925840wic.0
        for <linux-mm@kvack.org>; Sat, 30 May 2015 13:53:01 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.13])
        by mx.google.com with ESMTPS id s9si10628128wia.28.2015.05.30.13.52.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 13:53:00 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 2/4] devm: fix ioremap_cache() usage
Date: Sat, 30 May 2015 22:52:19 +0200
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com> <20150530185929.32590.22873.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150530185929.32590.22873.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201505302252.19647.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, hmh@hmh.eng.br, tj@kernel.org, hch@lst.de

On Saturday 30 May 2015, Dan Williams wrote:
> @@ -154,7 +148,7 @@ void __iomem *devm_ioremap_resource(struct device *dev, struct resource *res)
>         }
>  
>         if (res->flags & IORESOURCE_CACHEABLE)
> -               dest_ptr = devm_ioremap(dev, res->start, size);
> +               dest_ptr = devm_ioremap_cache(dev, res->start, size);
>         else
>                 dest_ptr = devm_ioremap_nocache(dev, res->start, size);

I think the existing uses of IORESOURCE_CACHEABLE are mostly bugs, so changing
the behavior here may cause more problems than it solves.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
