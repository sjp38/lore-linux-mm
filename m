Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8FF36B02A4
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 11:51:43 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id m12so2665096wrm.1
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 08:51:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h1sor5501820wrc.16.2018.01.08.08.51.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 08:51:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180108161435.e3jjrttk57lib63a@gmail.com>
References: <20171123165226.32582-1-aneesh.kumar@linux.vnet.ibm.com> <20180108161435.e3jjrttk57lib63a@gmail.com>
From: Philippe Ombredanne <pombredanne@nexb.com>
Date: Mon, 8 Jan 2018 17:51:01 +0100
Message-ID: <CAOFm3uHbs7_8+YWo9-8AWauK7Hx8E-v8M1w6Du23ZUvHHfFOjw@mail.gmail.com>
Subject: Re: [PATCH v4] selftest/vm: Move the 128 TB mmap boundary test to the
 generic VM directory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H . Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Anesh,

On Mon, Jan 8, 2018 at 5:14 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> Architectures like ppc64 do support mmap hint addr based large address space
>> selection. This test can be run on those architectures too. Move the test to
>> selftest/vm so that other archs can use the same.
>>
>> We also add a few new test scenarios in this patch. We do test few boundary
>> condition before we do a high address mmap. ppc64 use the addr limit to validate
>> addr in the fault path. We had bugs in this area w.r.t slb fault handling
>> before we updated the addr limit.
>>
>> We also touch the allocated space to make sure we don't have any bugs in the
>> fault handling path.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

<snip>

> --- /dev/null
> +++ b/tools/testing/selftests/vm/va_128TBswitch.c
> @@ -0,0 +1,297 @@
> +/*
> + *
> + * Authors: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> + * Authors: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License, version 2, as
> + * published by the Free Software Foundation.
> +
> + * This program is distributed in the hope that it would be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> + *
> + */

Would you mind using an SPDX tag instead of this fine legalese?
See Thomas doc [1] for details.
Thanks!

[1] https://lkml.org/lkml/2017/12/28/323
-- 
Cordially
Philippe Ombredanne

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
