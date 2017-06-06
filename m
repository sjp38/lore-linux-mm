Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 093F36B02F4
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 12:17:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o74so67949662pfi.6
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 09:17:43 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 203si33276281pfc.344.2017.06.06.09.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 09:17:42 -0700 (PDT)
Subject: Re: [RFC] mm,drm/i915: Mark pinned shmemfs pages as unevictable
References: <20170606120436.8683-1-chris@chris-wilson.co.uk>
 <20170606121418.GM1189@dhcp22.suse.cz>
 <149675247191.14666.5385909547703846037@mail.alporthouse.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8774b0c2-ffc1-698a-e144-d0530cbd9382@intel.com>
Date: Tue, 6 Jun 2017 09:17:41 -0700
MIME-Version: 1.0
In-Reply-To: <149675247191.14666.5385909547703846037@mail.alporthouse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.com>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Matthew Auld <matthew.auld@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>

On 06/06/2017 05:34 AM, Chris Wilson wrote:
> With respect to i915, we may not be the sole owner of the page at the
> point where we call shmem_read_mapping_page_gfp() as it can mmapped or
> accessed directly via the mapping internally. It is just at this point
> we know that the page will not be returned to the system until we have
> finished using it with the GPU.
> 
> An API that didn't assume the page was locked or require exclusive
> ownership would be needed for random driver usage like i915.ko

Why do you think exclusive ownership is required, btw?  What does
exclusive ownership mean, anyway?  page_count()==1 and you old the old
reference?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
