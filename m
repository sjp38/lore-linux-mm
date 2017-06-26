Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 402D36B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:43:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s65so324390wma.15
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:43:10 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id g186si8352022wmf.196.2017.06.26.02.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 02:43:07 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id z45so28895554wrb.2
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:43:07 -0700 (PDT)
Date: Mon, 26 Jun 2017 11:43:04 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove by not
 freeing pud v3
Message-ID: <20170626094304.bmvsia5zpixbazpu@gmail.com>
References: <20170624180514.3821-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170624180514.3821-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Logan Gunthorpe <logang@deltatee.com>, Andrew Morton <akpm@linux-foundation.org>


* jglisse@redhat.com <jglisse@redhat.com> wrote:

> From: Jerome Glisse <jglisse@redhat.com>
> 
> With commit af2cf278ef4f we no longer free pud so that we do not
> have synchronize all pgd on hotremove/vfree. But the new 5 level
> page table patchset reverted that for 4 level page table.
> 
> This patch restore af2cf278ef4f and disable free_pud() if we are
> in the 4 level page table case thus avoiding BUG_ON() after hot-
> remove.
> 
> af2cf278ef4f x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()

Am I correct that the _real_ buggy commit that introduced the breakage in v4.12 
is:

  f2a6a7050109: ("x86: Convert the rest of the code to support p4d_t")

... right?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
