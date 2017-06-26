Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD6E6B02F4
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 10:49:39 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g2so1194183qta.14
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 07:49:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f19si251249qtc.27.2017.06.26.07.49.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 07:49:38 -0700 (PDT)
Date: Mon, 26 Jun 2017 10:49:34 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove by not
 freeing pud v3
Message-ID: <20170626144934.GA3706@redhat.com>
References: <20170624180514.3821-1-jglisse@redhat.com>
 <20170626094304.bmvsia5zpixbazpu@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170626094304.bmvsia5zpixbazpu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Logan Gunthorpe <logang@deltatee.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jun 26, 2017 at 11:43:04AM +0200, Ingo Molnar wrote:
> 
> * jglisse@redhat.com <jglisse@redhat.com> wrote:
> 
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > With commit af2cf278ef4f we no longer free pud so that we do not
> > have synchronize all pgd on hotremove/vfree. But the new 5 level
> > page table patchset reverted that for 4 level page table.
> > 
> > This patch restore af2cf278ef4f and disable free_pud() if we are
> > in the 4 level page table case thus avoiding BUG_ON() after hot-
> > remove.
> > 
> > af2cf278ef4f x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()
> 
> Am I correct that the _real_ buggy commit that introduced the breakage in v4.12 
> is:
> 
>   f2a6a7050109: ("x86: Convert the rest of the code to support p4d_t")
> 
> ... right?

Correct.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
