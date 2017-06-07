Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5E66B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 06:47:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a3so901992wma.12
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 03:47:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z52sor237053edb.19.2017.06.07.03.47.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 03:47:17 -0700 (PDT)
Date: Wed, 7 Jun 2017 13:47:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove
Message-ID: <20170607104715.5niuwk42fhahbftk@node.shutemov.name>
References: <20170606173512.7378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170606173512.7378-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Logan Gunthorpe <logang@deltatee.com>

On Tue, Jun 06, 2017 at 01:35:12PM -0400, Jerome Glisse wrote:
> With commit af2cf278ef4f we no longer free pud so that we
> do not have synchronize all pgd on hotremove/vfree. But the
> new 5 level page table code re-added that code f2a6a705 and
> thus we now trigger a BUG_ON() l128 in sync_global_pgds()
> 
> This patch remove free_pud() like in af2cf278ef4f

Good catch. Thanks!

But I think we only need to skip free_pud_table() for 4-level paging.
If we don't we would leave 513 page tables around instead of one in
5-level paging case.

I don't think it's acceptable.

And please use patch subject lines along with commit hashes to simplify
reading commit message.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
