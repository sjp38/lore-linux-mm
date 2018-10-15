Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6514A6B0003
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 18:11:46 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so15580271pgr.8
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:11:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f8-v6si11865842pgu.370.2018.10.15.15.11.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 15:11:45 -0700 (PDT)
Date: Mon, 15 Oct 2018 15:11:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: thp: relocate flush_cache_range() in
 migrate_misplaced_transhuge_page()
Message-Id: <20181015151143.0d37ffe1492f5f7e51170607@linux-foundation.org>
In-Reply-To: <20181015202311.7209-1-aarcange@redhat.com>
References: <20181013002430.698-4-aarcange@redhat.com>
	<20181015202311.7209-1-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Aaron Tomlin <atomlin@redhat.com>, Mel Gorman <mgorman@suse.de>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, 15 Oct 2018 16:23:11 -0400 Andrea Arcangeli <aarcange@redhat.com> wrote:

> There should be no cache left by the time we overwrite the old
> transhuge pmd with the new one. It's already too late to flush through
> the virtual address because we already copied the page data to the new
> physical address.
> 
> So flush the cache before the data copy.
> 
> Also delete the "end" variable to shutoff a "unused variable" warning
> on x86 where flush_cache_range() is a noop.

What will be the runtime effects of this change?
