Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 61A248E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:50:09 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so12591369pgc.22
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 05:50:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j15sor765575pgc.41.2019.01.14.05.50.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 05:50:08 -0800 (PST)
Date: Mon, 14 Jan 2019 16:50:02 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
Message-ID: <20190114135001.w2wpql53zitellus@kshutemo-mobl1>
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Boaz Harrosh <boazh@netapp.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 11, 2019 at 03:28:37PM -0800, Mike Kravetz wrote:
> Ok, I just wanted to ask the question.  I've seen application code doing
> the 'mmap sufficiently large area' then unmap to get desired alignment
> trick.  Was wondering if there was something we could do to help.

Application may want to get aligned allocation for different reasons.
It should be okay for userspace to ask for size + (alignment - PAGE_SIZE)
and then round up the address to get the alignment. We basically do the
same on kernel side.

For THP, I believe, kernel already does The Right Thing™ for most users.
User still may want to get speific range as THP (to avoid false sharing or
something). But still I believe userspace has all required tools to get it
right.

-- 
 Kirill A. Shutemov
