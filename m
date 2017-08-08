Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 491CA6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 11:46:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k14so17347746qkl.7
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 08:46:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w188si1262025qkd.29.2017.08.08.08.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 08:46:11 -0700 (PDT)
Message-ID: <1502207168.6577.25.camel@redhat.com>
Subject: Re: [PATCH v2 0/2] mm,fork,security: introduce MADV_WIPEONFORK
From: Rik van Riel <riel@redhat.com>
Date: Tue, 08 Aug 2017 11:46:08 -0400
In-Reply-To: <0324df31-717d-32c1-95ef-351c5b23105f@oracle.com>
References: <20170806140425.20937-1-riel@redhat.com>
	 <a0d79f77-f916-d3d6-1d61-a052581dbd4a@oracle.com>
	 <bfdab709-e5b2-0d26-1c0f-31535eda1678@redhat.com>
	 <1502198148.6577.18.camel@redhat.com>
	 <0324df31-717d-32c1-95ef-351c5b23105f@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Florian Weimer <fweimer@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, colm@allcosts.net, akpm@linux-foundation.org, keescook@chromium.org, luto@amacapital.net, wad@chromium.org, mingo@kernel.org, kirill@shutemov.name, dave.hansen@intel.com

On Tue, 2017-08-08 at 08:19 -0700, Mike Kravetz wrote:

> The other question I was trying to bring up is "What does
> MADV_WIPEONFORK
> mean for various types of mappings?"A A For example, if we allow
> MADV_WIPEONFORK on a file backed mapping what does that mapping look
> like in the child after fork?A A Does it have any connection at all to
> the
> file?A A Or, do we drop all references to the file and essentially
> transform
> it to a private (or shared?) anonymous mapping after fork.A A What
> about
> System V shared memory?A A What about hugetlb?

My current patch turns any file-backed VMA into an empty
anonymous VMA if MADV_WIPEONFORK was used on that VMA.

> If the use case is fairly specific, then perhaps it makes sense to
> make MADV_WIPEONFORK not applicable (EINVAL) for mappings where the
> result is 'questionable'.

That would be a question for Florian and Colm.

If they are OK with MADV_WIPEONFORK only working on
anonymous VMAs (no file mapping), that certainly could
be implemented.

On the other hand, I am not sure that introducing cases
where MADV_WIPEONFORK does not implement wipe-on-fork
semantics would reduce user confusion...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
