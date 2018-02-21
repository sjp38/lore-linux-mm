Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 643A56B0007
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 18:59:04 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j21so2643805wre.20
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 15:59:04 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id t63si158316wrc.339.2018.02.21.15.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Feb 2018 15:59:01 -0800 (PST)
Subject: Re: mmotm 2018-02-21-14-48 uploaded (mm/page_alloc.c on UML)
References: <20180221224839.MqsDtkGCK%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <7bcc52db-57eb-45b0-7f20-c93a968599cd@infradead.org>
Date: Wed, 21 Feb 2018 15:58:41 -0800
MIME-Version: 1.0
In-Reply-To: <20180221224839.MqsDtkGCK%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, richard -rw- weinberger <richard.weinberger@gmail.com>, Eugeniu Rosca <erosca@de.adit-jv.com>

On 02/21/2018 02:48 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2018-02-21-14-48 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 
> You will need quilt to apply these patches to the latest Linus release (4.x
> or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
> 
> The file broken-out.tar.gz contains two datestamp files: .DATE and
> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> followed by the base kernel version against which this patch series is to
> be applied.

um (or uml) defconfig on i386 and/or x86_64:

../mm/page_alloc.c: In function 'memmap_init_zone':
../mm/page_alloc.c:5450:5: error: implicit declaration of function 'memblock_next_valid_pfn' [-Werror=implicit-function-declaration]
     pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
     ^


probably (?):
From: Eugeniu Rosca <erosca@de.adit-jv.com>
Subject: mm: page_alloc: skip over regions of invalid pfns on UMA


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
