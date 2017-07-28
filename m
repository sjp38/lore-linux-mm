Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83B0C6B052D
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 08:02:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d5so116777786pfg.3
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 05:02:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f34si13079238plf.739.2017.07.28.05.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 05:02:37 -0700 (PDT)
Message-ID: <1501243352.6305.6.camel@linux.intel.com>
Subject: Re: [PATCH 01/21] mm/shmem: introduce shmem_file_setup_with_mnt
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Fri, 28 Jul 2017 15:02:32 +0300
In-Reply-To: <20170725192133.2012-2-matthew.auld@intel.com>
References: <20170725192133.2012-1-matthew.auld@intel.com>
	 <20170725192133.2012-2-matthew.auld@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org
Cc: Matthew Auld <matthew.auld@intel.com>, intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>

Ping on the core MM folks.

We'd need either an ack or nack on this one to proceed with the huge
page work for i915.

Regards, Joonas

On ti, 2017-07-25 at 20:21 +0100, Matthew Auld wrote:
> We are planning to use our own tmpfs mnt in i915 in place of the
> shm_mnt, such that we can control the mount options, in particular
> huge=, which we require to support huge-gtt-pages. So rather than roll
> our own version of __shmem_file_setup, it would be preferred if we could
> just give shmem our mnt, and let it do the rest.
> 
> Signed-off-by: Matthew Auld <matthew.auld@intel.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org
> ---
> A include/linux/shmem_fs.h |A A 2 ++
> A mm/shmem.cA A A A A A A A A A A A A A A | 30 ++++++++++++++++++++++--------
> A 2 files changed, 24 insertions(+), 8 deletions(-)

<SNIP>

-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
