Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 24E436B0031
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 20:43:47 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so6271741pab.22
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 17:43:46 -0700 (PDT)
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
        by mx.google.com with ESMTPS id h13si5418969pdl.300.2014.07.07.17.43.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 17:43:45 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so6248194pdj.0
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 17:43:45 -0700 (PDT)
Message-ID: <53BB3EBC.8050005@linaro.org>
Date: Tue, 08 Jul 2014 08:43:40 +0800
From: Alex Shi <alex.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] x86: mm: new tunable for single vs full TLB flush
References: <20140421182418.81CF7519@viggo.jf.intel.com> <20140421182426.D6DD1E8F@viggo.jf.intel.com> <20140424103727.GT23991@suse.de> <53BADC49.6000600@sr71.net>
In-Reply-To: <53BADC49.6000600@sr71.net>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, Mel Gorman <mgorman@suse.de>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, ak@linux.intel.com, riel@redhat.com, dave.hansen@linux.intel.com, "H. Peter Anvin" <hpa@zytor.com>

On 07/08/2014 01:43 AM, Dave Hansen wrote:
> On 04/24/2014 03:37 AM, Mel Gorman wrote:
>>> +Despite the fact that a single individual flush on x86 is
>>>> +guaranteed to flush a full 2MB, hugetlbfs always uses the full
>>>> +flushes.  THP is treated exactly the same as normal memory.
>>>> +
>> You are the second person that told me this and I felt the manual was
>> unclear on this subject. I was told that it might be a documentation bug
>> but because this discussion was in a bar I completely failed to follow up
>> on it. 
> 
> For the record...  There's a new version of the Intel SDM out, and it
> contains some clarifications.  They're the easiest to find in this
> document which highlights the deltas from the last version:
> 
>> http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developers-manual.pdf
> 
> The documentation for invlpg itself has a new footnote, and there's also
> a little bit of new text in section "4.10.2.3 Details of TLB Use".
> 
> The footnotes say:
> 
> 	If the paging structures map the linear address using a page
> 	larger than 4 KBytes and there are multiple TLB entries for
> 	that page (see Section 4.10.2.3), the instruction (invlpg)
> 	invalidates all of them
> 
> I hope that clears up some of the ambiguity over invlpg.
> 

Uh, AFAICT, the invlpg on large page has no clear effect on data
retrieving, on all Intel CPU till ivybridge. No testing on later CPUs.

-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
