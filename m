Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25C8E6B0007
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 23:27:25 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id c5-v6so2949234ioa.0
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 20:27:25 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id y140-v6si1593573iof.56.2018.10.23.20.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Oct 2018 20:27:20 -0700 (PDT)
Subject: Re: [PATCH 06/17] prmem: test cases for memory protection
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-7-igor.stoppa@huawei.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a6c74bb1-bd0c-ed8a-1dd3-b04f2e3c78d4@infradead.org>
Date: Tue, 23 Oct 2018 20:27:06 -0700
MIME-Version: 1.0
In-Reply-To: <20181023213504.28905-7-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/23/18 2:34 PM, Igor Stoppa wrote:
> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
> index 9a7b8b049d04..57de5b3c0bae 100644
> --- a/mm/Kconfig.debug
> +++ b/mm/Kconfig.debug
> @@ -94,3 +94,12 @@ config DEBUG_RODATA_TEST
>      depends on STRICT_KERNEL_RWX
>      ---help---
>        This option enables a testcase for the setting rodata read-only.
> +
> +config DEBUG_PRMEM_TEST
> +    tristate "Run self test for protected memory"
> +    depends on STRICT_KERNEL_RWX
> +    select PRMEM
> +    default n
> +    help
> +      Tries to verify that the memory protection works correctly and that
> +      the memory is effectively protected.

Hi,

a. It seems backwards (or upside down) to have a test case select a feature (PRMEM)
instead of depending on that feature.

b. Since PRMEM depends on MMU (in patch 04/17), the "select" here could try to
enabled PRMEM even when MMU is not enabled.

Changing this to "depends on PRMEM" would solve both of these issues.

c. Don't use "default n".  That is already the default.


thanks,
-- 
~Randy
