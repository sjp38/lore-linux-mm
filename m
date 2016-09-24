Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25CF16B0283
	for <linux-mm@kvack.org>; Sat, 24 Sep 2016 18:54:19 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t83so394167458oie.0
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 15:54:19 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id o49si9143058oto.193.2016.09.24.15.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Sep 2016 15:54:18 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id a62so11270382oib.1
        for <linux-mm@kvack.org>; Sat, 24 Sep 2016 15:54:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160924210443.GA106728@black.fi.intel.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CA+55aFwNYAFc4KePvx50kwZ3A+8yvCCK_6nYYxG9fqTPhFzQoQ@mail.gmail.com>
 <DM2PR21MB0089CA7DCF4845DB02E0E05FCBC80@DM2PR21MB0089.namprd21.prod.outlook.com>
 <CA+55aFwiro5MvOozcF50z4kMBk7rVBViLw8yXX1w-1mCZVAsDA@mail.gmail.com> <20160924210443.GA106728@black.fi.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 24 Sep 2016 15:54:17 -0700
Message-ID: <CA+55aFzOvPJbVFvssmiOHuCKG_z-FbGO8-EzVnShDCVmAc1MQQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Sat, Sep 24, 2016 at 2:04 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> Well, my ext4-with-huge-pages patchset[1] uses multi-order entries.
> It also converts shmem-with-huge-pages and hugetlb to them.

Ok, so that code actually has a chance of being used. I guess we'll
not remove it. But I *would* like this subtle issue to have a comment
around that odd cast/and/mask thing.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
