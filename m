Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62D4A6B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 20:43:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a69so75988883pfa.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 17:43:09 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id y7si2766379pae.92.2016.06.15.17.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 17:43:08 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id hf6so2446258pac.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 17:43:08 -0700 (PDT)
Date: Thu, 16 Jun 2016 09:43:07 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCHv9-rebased2 03/37] mm, thp: fix locking inconsistency in
 collapse_huge_page
Message-ID: <20160616004307.GA658@swordfish>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466021202-61880-4-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Rik van Riel <riel@redhat.com>

Hello,

On (06/15/16 23:06), Kirill A. Shutemov wrote:
[..]
> After creating revalidate vma function, locking inconsistency occured
> due to directing the code path to wrong label. This patch directs
> to correct label and fix the inconsistency.
> 
> Related commit that caused inconsistency:
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=da4360877094368f6dfe75bbe804b0f0a5d575b0


as far as I remember, Vlastimil had "one more thing" to ask
http://marc.info/?l=linux-mm&m=146521832732210&w=2

or is it safe?


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
