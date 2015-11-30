Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id C731A6B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:12:30 -0500 (EST)
Received: by ykfs79 with SMTP id s79so197501741ykf.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 11:12:30 -0800 (PST)
Received: from mail-yk0-x229.google.com (mail-yk0-x229.google.com. [2607:f8b0:4002:c07::229])
        by mx.google.com with ESMTPS id s64si8457683ywf.164.2015.11.30.11.12.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 11:12:30 -0800 (PST)
Received: by ykdv3 with SMTP id v3so195927605ykd.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 11:12:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
References: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
Date: Mon, 30 Nov 2015 11:12:29 -0800
Message-ID: <CAPcyv4jKxV-Uq2+AbwVyvTyb8SNeHaVXTf5A_YYDiptNkPnfFQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Sun, Nov 29, 2015 at 9:08 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> The full set in context with other changes is available here:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm libnvdimm-pending

Note, I refreshed the branch to fix a randconfig compile error
reported by the kbuild robot, but no other substantive changes
relative to the posted patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
