Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id A88616B00CE
	for <linux-mm@kvack.org>; Fri, 14 Nov 2014 20:41:04 -0500 (EST)
Received: by mail-vc0-f180.google.com with SMTP id im6so2777971vcb.25
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 17:41:04 -0800 (PST)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com. [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id ez5si18813442vdc.25.2014.11.14.17.41.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Nov 2014 17:41:03 -0800 (PST)
Received: by mail-vc0-f181.google.com with SMTP id le20so2848479vcb.40
        for <linux-mm@kvack.org>; Fri, 14 Nov 2014 17:41:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1415971986-16143-1-git-send-email-mgorman@suse.de>
References: <1415971986-16143-1-git-send-email-mgorman@suse.de>
Date: Fri, 14 Nov 2014 17:41:02 -0800
Message-ID: <CA+55aFx-_EU6pgSY61YsA8qYVtNnz8PeJzU=h-NQy8pMJU-jxQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/7] Replace _PAGE_NUMA with PAGE_NONE protections
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>

On Fri, Nov 14, 2014 at 5:32 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> This series is very heavily based on patches from Linus and Aneesh to
> replace the existing PTE/PMD NUMA helper functions with normal change
> protections. I did alter and add parts of it but I consider them relatively
> minor contributions. Note that the signed-offs here need addressing. I
> couldn't use "From" or Signed-off-by from the original authors as the
> patches had to be broken up and they were never signed off. I expect the
> two people involved will just stick their signed-off-by on it.

Feel free to just take authorship of my parts, and make my
"Needs-sign-off's" be just "Acked-by:"

Or alternatively keep them as "Signed-off-by:", even when it looks a
bit odd if it doesn't have a "From:" me, when the actual patch won't
then actually go through me - I'm assuming this will come in through
the -mm tree.

As to the ppc parts, obviously it would be good to have Aneesh re-test
the series..

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
