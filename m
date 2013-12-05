Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 144456B003C
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 13:51:22 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so3935080qcx.18
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 10:51:21 -0800 (PST)
Received: from mail-qa0-x22f.google.com (mail-qa0-x22f.google.com [2607:f8b0:400d:c00::22f])
        by mx.google.com with ESMTPS id e7si41645864qez.74.2013.12.05.10.51.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 10:51:21 -0800 (PST)
Received: by mail-qa0-f47.google.com with SMTP id w5so82623qac.6
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 10:51:20 -0800 (PST)
Date: Thu, 5 Dec 2013 13:51:16 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation apis
Message-ID: <20131205185116.GA27274@mtj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com>
 <20131203232445.GX8277@htj.dyndns.org>
 <52A0AB34.2030703@ti.com>
 <20131205165325.GA24062@mtj.dyndns.org>
 <902E09E6452B0E43903E4F2D568737AB097B26B2@DNCE04.ent.ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <902E09E6452B0E43903E4F2D568737AB097B26B2@DNCE04.ent.ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Strashko, Grygorii" <grygorii.strashko@ti.com>
Cc: "Shilimkar, Santosh" <santosh.shilimkar@ti.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hey,

On Thu, Dec 05, 2013 at 06:48:21PM +0000, Strashko, Grygorii wrote:
> +/* Fall back to all the existing bootmem APIs */
> +#define memblock_virt_alloc(x) \
> +       __alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
> 
> which will be transformed to 
> +/* Fall back to all the existing bootmem APIs */
> +#define memblock_virt_alloc(x, align) \
> +       __alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)
> 
> and used as
> 
> memblock_virt_alloc(size, 0);
> 
> so, by default bootmem code will use 0 as default alignment and not SMP_CACHE_BYTES
> and that is wrong.

Just translate it to SMP_CACHE_BYTES?  Am I missing something here?
You're defining a new API which wraps around two interfaces.  Wrap
them so that they show the same desired behavior?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
