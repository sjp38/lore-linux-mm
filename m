Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA8CE6B000A
	for <linux-mm@kvack.org>; Fri, 25 May 2018 11:38:28 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id z195-v6so2880540ywa.0
        for <linux-mm@kvack.org>; Fri, 25 May 2018 08:38:28 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id y80-v6si6166061ywy.230.2018.05.25.08.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 May 2018 08:38:27 -0700 (PDT)
Date: Fri, 25 May 2018 15:38:26 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH -V2 -mm 0/4] mm, huge page: Copy target sub-page last
 when copy huge page
In-Reply-To: <20180524005851.4079-1-ying.huang@intel.com>
Message-ID: <0100016397f379e8-f651e3ed-3646-4423-8cd3-9ea61666a12b-000000@email.amazonses.com>
References: <20180524005851.4079-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, 24 May 2018, Huang, Ying wrote:

> If the cache contention is heavy when copying the huge page, and we
> copy the huge page from the begin to the end, it is possible that the
> begin of huge page is evicted from the cache after we finishing
> copying the end of the huge page.  And it is possible for the
> application to access the begin of the huge page after copying the
> huge page.

Isnt there a better way to zero the remaining pages? Something that has no
cache impact like a non temporal store? So the remaining cache will not be
evicted?

https://www.felixcloutier.com/x86/MOVNTI.html
