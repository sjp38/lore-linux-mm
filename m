Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 177016B0036
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 08:26:19 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so751111pbc.23
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 05:26:18 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CACz4_2er-_Xa8oRo_JJTC+HZtDTAcjJ+cNTjrXLhN0Dm7BtXFQ@mail.gmail.com>
References: <20131015001201.GC3432@hippobay.mtv.corp.google.com>
 <20131015100213.A0189E0090@blue.fi.intel.com>
 <CACz4_2er-_Xa8oRo_JJTC+HZtDTAcjJ+cNTjrXLhN0Dm7BtXFQ@mail.gmail.com>
Subject: Re: [PATCH 02/12] mm, thp, tmpfs: support to add huge page into page
 cache for tmpfs
Content-Transfer-Encoding: 7bit
Message-Id: <20131016122611.69CA0E0090@blue.fi.intel.com>
Date: Wed, 16 Oct 2013 15:26:11 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ning Qu <quning@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Ning Qu wrote:
> Yes, I can try. The code is pretty much similar with some minor difference.
> 
> One thing I can do is to move the spin lock part (together with the
> corresponding err handling into a common function.
> 
> The only problem I can see right now is we need the following
> additional line for shm:
> 
> __mod_zone_page_state(page_zone(page), NR_SHMEM, nr);
> 
> Which means we need to tell if it's coming from shm or not, is that OK
> to add additional parameter just for that? Or is there any other
> better way we can infer that information? Thanks!

I think you can account NR_SHMEM after common code succeed, don't you?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
