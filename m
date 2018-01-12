Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90D9E6B0033
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 10:26:51 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v18so3573241wrf.21
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 07:26:51 -0800 (PST)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id x66si2444757wmb.268.2018.01.12.07.26.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 07:26:50 -0800 (PST)
Subject: Re: [PATCH] mm, THP: vmf_insert_pfn_pud depends on
 CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
References: <1515660811-12293-1-git-send-email-aghiti@upmem.com>
 <20180111100620.GY1732@dhcp22.suse.cz>
 <71853228-0beb-1e69-df47-59fa1bc5bd2f@upmem.com>
 <20180111162825.4cdaba2a21d8f15b21c45c75@linux-foundation.org>
From: Alexandre Ghiti <aghiti@upmem.com>
Message-ID: <01df063e-8cfd-11fd-a335-1e4a26377f95@upmem.com>
Date: Fri, 12 Jan 2018 16:26:09 +0100
MIME-Version: 1.0
In-Reply-To: <20180111162825.4cdaba2a21d8f15b21c45c75@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, gregkh@linuxfoundation.org, n-horiguchi@ah.jp.nec.com, mark.rutland@arm.com, linux-kernel@vger.kernel.org

On 12/01/2018 01:28, Andrew Morton wrote:
> On Thu, 11 Jan 2018 14:05:34 +0100 Alexandre Ghiti <aghiti@upmem.com> wrote:
>
>> On 11/01/2018 11:06, Michal Hocko wrote:
>>> On Thu 11-01-18 09:53:31, Alexandre Ghiti wrote:
>>>> The only definition of vmf_insert_pfn_pud depends on
>>>> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD being defined. Then its declaration in
>>>> include/linux/huge_mm.h should have the same restriction so that we do
>>>> not expose this function if CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is
>>>> not defined.
>>> Why is this a problem? Compiler should simply throw away any
>>> declarations which are not used?
>> It is not a big problem but surrounding the declaration with the #ifdef
>> makes the compilation of external modules fail with an "error: implicit
>> declaration of function vmf_insert_pfn_pud" if
>> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is not defined. I think it is
>> cleaner than generating a .ko which would not load anyway.
> Disagree.  We'd have to put an absolutely vast amount of complex and
> hard-to-maintain ifdefs in headers if we were to ensure that such
> errors were to be detected at compile time.
>
> Whereas if we defer the detection of the errors until link time (or
> depmod or modprobe time) then yes, a handful of people will detect
> their mistake a minute or three later but that's a small cost compared
> to permanently and badly messing up the header files.
Ok, thanks for your time and explanations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
