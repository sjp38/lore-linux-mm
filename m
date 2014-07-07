Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9098F6B0036
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 13:43:43 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so5753845pde.3
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 10:43:43 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id bc15si5094522pdb.17.2014.07.07.10.43.38
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 10:43:39 -0700 (PDT)
Message-ID: <53BADC49.6000600@sr71.net>
Date: Mon, 07 Jul 2014 10:43:37 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] x86: mm: new tunable for single vs full TLB flush
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182426.D6DD1E8F@viggo.jf.intel.com> <20140424103727.GT23991@suse.de>
In-Reply-To: <20140424103727.GT23991@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, alex.shi@linaro.org, dave.hansen@linux.intel.com, "H. Peter Anvin" <hpa@zytor.com>

On 04/24/2014 03:37 AM, Mel Gorman wrote:
>> +Despite the fact that a single individual flush on x86 is
>> > +guaranteed to flush a full 2MB, hugetlbfs always uses the full
>> > +flushes.  THP is treated exactly the same as normal memory.
>> > +
> You are the second person that told me this and I felt the manual was
> unclear on this subject. I was told that it might be a documentation bug
> but because this discussion was in a bar I completely failed to follow up
> on it. 

For the record...  There's a new version of the Intel SDM out, and it
contains some clarifications.  They're the easiest to find in this
document which highlights the deltas from the last version:

> http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developers-manual.pdf

The documentation for invlpg itself has a new footnote, and there's also
a little bit of new text in section "4.10.2.3 Details of TLB Use".

The footnotes say:

	If the paging structures map the linear address using a page
	larger than 4 KBytes and there are multiple TLB entries for
	that page (see Section 4.10.2.3), the instruction (invlpg)
	invalidates all of them

I hope that clears up some of the ambiguity over invlpg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
