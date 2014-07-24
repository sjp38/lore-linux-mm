Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E9E8E6B0035
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 08:51:02 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so3636686pdb.13
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 05:51:02 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id rf4si2959763pdb.213.2014.07.24.05.51.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 05:51:02 -0700 (PDT)
Message-ID: <53D100A2.3090404@oracle.com>
Date: Thu, 24 Jul 2014 08:48:34 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com> <1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com> <53D07E96.5000006@oracle.com> <53D0AD7E.3050705@samsung.com>
In-Reply-To: <53D0AD7E.3050705@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On 07/24/2014 02:53 AM, Andrey Ryabinin wrote:
> On 07/24/14 07:33, Sasha Levin wrote:
>> > On 02/27/2014 02:53 PM, Kirill A. Shutemov wrote:
>>> >> The patch introduces new vm_ops callback ->map_pages() and uses it for
>>> >> mapping easy accessible pages around fault address.
>>> >>
>>> >> On read page fault, if filesystem provides ->map_pages(), we try to map
>>> >> up to FAULT_AROUND_PAGES pages around page fault address in hope to
>>> >> reduce number of minor page faults.
>>> >>
>>> >> We call ->map_pages first and use ->fault() as fallback if page by the
>>> >> offset is not ready to be mapped (cold page cache or something).
>>> >>
>>> >> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> >> ---
>> > 
>> > Hi all,
>> > 
>> > This patch triggers use-after-free when fuzzing using trinity and the KASAN
>> > patchset.
>> > 
> I think this should be fixed already by following patch:
> 
> From: Konstantin Khlebnikov <koct9i@gmail.com>
> Subject: mm: do not call do_fault_around for non-linear fault

I don't think so. It's supposed to deal with a different issue, and it was already
in my -next tree which triggered the issue I've reported.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
