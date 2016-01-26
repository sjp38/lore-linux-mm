Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 766276B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:08:06 -0500 (EST)
Received: by mail-yk0-f173.google.com with SMTP id k129so217086175yke.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:08:06 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id d71si1091457ybh.210.2016.01.26.13.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 13:08:05 -0800 (PST)
Received: by mail-yk0-x22d.google.com with SMTP id u68so87614509ykd.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:08:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453841853-11383-13-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
	<1453841853-11383-13-git-send-email-bp@alien8.de>
Date: Tue, 26 Jan 2016 13:08:05 -0800
Message-ID: <CAPcyv4j1g2FRvMZfn28B7KkTHmv4z5nmca2bS7e4Xi3dWHqSTg@mail.gmail.com>
Subject: Re: [PATCH 12/17] memremap: Change region_intersects() to take @flags
 and @desc
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jakub Sitnicki <jsitnicki@gmail.com>, Jan Kara <jack@suse.cz>, Jiang Liu <jiang.liu@linux.intel.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Jan 26, 2016 at 12:57 PM, Borislav Petkov <bp@alien8.de> wrote:
> From: Toshi Kani <toshi.kani@hpe.com>
>
> Change region_intersects() to identify a target with @flags and @desc,
> instead of @name with strcmp().
>
> Change the callers of region_intersects(), memremap() and
> devm_memremap(), to set IORESOURCE_SYSTEM_RAM in @flags and
> IORES_DESC_NONE in @desc when searching System RAM.
>
> Also, export region_intersects() so that the ACPI EINJ error injection
> driver can call this function in a later patch.
>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Dan Williams <dan.j.williams@intel.com>

Acked-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
