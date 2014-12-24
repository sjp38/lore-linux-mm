Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 488D26B0071
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 09:16:19 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id 10so6842929lbg.19
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 06:16:18 -0800 (PST)
Received: from cassarossa.samfundet.no (cassarossa.samfundet.no. [2001:67c:29f4::29])
        by mx.google.com with ESMTPS id a4si25616037lbp.132.2014.12.24.06.16.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 24 Dec 2014 06:16:18 -0800 (PST)
Date: Wed, 24 Dec 2014 15:15:24 +0100
From: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Subject: Re: [PATCH 13/38] avr32: drop _PAGE_FILE and pte_file()-related
 helpers
Message-ID: <20141224141524.GA3091@samfundet.no>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1419423766-114457-14-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419423766-114457-14-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Haavard Skinnemoen <hskinnemoen@gmail.com>

Around Wed 24 Dec 2014 14:22:21 +0200 or thereabout, Kirill A. Shutemov wrote:
> We've replaced remap_file_pages(2) implementation with emulation.
> Nobody creates non-linear mapping anymore.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> ---
>  arch/avr32/include/asm/pgtable.h | 25 -------------------------
>  1 file changed, 25 deletions(-)

Oooh, 25 lines less code, fantastic.

Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>

<snipp diff>

-- 
HcE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
