Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 74CF26B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 20:45:40 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 74so78319226oie.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 17:45:40 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id e89si15898971ote.206.2016.09.07.08.47.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 08:47:13 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id w78so31517653oie.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 08:47:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57CFA1A1.7060704@linux.vnet.ibm.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
 <147318058712.30325.12749411762275637099.stgit@dwillia2-desk3.amr.corp.intel.com>
 <57CFA1A1.7060704@linux.vnet.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 7 Sep 2016 08:47:13 -0700
Message-ID: <CAPcyv4hvv4nhE-9aO1p2+MsCDBAx-8kqwSUQ7FA15LZJAHz=8Q@mail.gmail.com>
Subject: Re: [PATCH 5/5] mm: cleanup pfn_t usage in track_pfn_insert()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Sep 6, 2016 at 10:12 PM, Anshuman Khandual
<khandual@linux.vnet.ibm.com> wrote:
> On 09/06/2016 10:19 PM, Dan Williams wrote:
>> Now that track_pfn_insert() is no longer used in the DAX path, it no
>> longer needs to comprehend pfn_t values.
>>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  arch/x86/mm/pat.c             |    4 ++--
>>  include/asm-generic/pgtable.h |    4 ++--
>>  mm/memory.c                   |    2 +-
>>  3 files changed, 5 insertions(+), 5 deletions(-)
>
> A small nit. Should not the arch/x86/mm/pat.c changes be separated out
> into a different patch ? Kind of faced little bit problem separating out
> generic core mm changes to that of arch specific mm changes when going
> through the commits in retrospect.

I'm going to drop this change.  Leaving it as is does no harm, and
users of pfn_t are likely to grow over time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
