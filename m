Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E79E6B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 14:41:52 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b10so3133884oia.7
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:41:52 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id h19si1354726otd.38.2017.04.24.11.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 11:41:51 -0700 (PDT)
Received: by mail-oi0-x22e.google.com with SMTP id y11so113639588oie.0
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:41:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170424182555.faoarzlpi4ilm5dt@black.fi.intel.com>
References: <CAA9_cmf7=aGXKoQFkzS_UJtznfRtWofitDpV2AyGwpaRGKyQkg@mail.gmail.com>
 <20170423233125.nehmgtzldgi25niy@node.shutemov.name> <CAPcyv4i8mBOCuA8k-A8RXGMibbnqHUsa3Ly+YcQbr0eCdjruUw@mail.gmail.com>
 <20170424173021.ayj3hslvfrrgrie7@node.shutemov.name> <CAPcyv4g74LT6sK2WgG6FnwQHCC5fNTwfqBPq1BY8PnZ7zwdGPw@mail.gmail.com>
 <20170424180158.y26m3kgzhpmawbhg@node.shutemov.name> <20170424182555.faoarzlpi4ilm5dt@black.fi.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 24 Apr 2017 11:41:51 -0700
Message-ID: <CAPcyv4iFhpSo-nbypHuZVZz7S92PwPx17bxUgMsksRHYPQkqEA@mail.gmail.com>
Subject: Re: get_zone_device_page() in get_page() and page_cache_get_speculative()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linux MM <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@redhat.com>, Dann Frazier <dann.frazier@canonical.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-tip-commits@vger.kernel.org

On Mon, Apr 24, 2017 at 11:25 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> On Mon, Apr 24, 2017 at 09:01:58PM +0300, Kirill A. Shutemov wrote:
>> On Mon, Apr 24, 2017 at 10:47:43AM -0700, Dan Williams wrote:
>> I think it's still better to do it on page_ref_* level.
>
> Something like patch below? What do you think?

>From a quick glance, I think this looks like the right way to go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
