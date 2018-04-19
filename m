Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3D906B0007
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 03:46:34 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u13-v6so14151864wre.1
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 00:46:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e49sor6658974eda.2.2018.04.22.00.46.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 00:46:33 -0700 (PDT)
Date: Thu, 19 Apr 2018 12:01:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and
 hugetlbfs
Message-ID: <20180419090119.5p5vos3vm57epr2j@node.shutemov.name>
References: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
 <2804a1d0-9d68-ac43-3041-9490147b52b5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2804a1d0-9d68-ac43-3041-9490147b52b5@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, viro@zeniv.linux.org.uk, nyc@holomorphy.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 18, 2018 at 01:26:35PM -0700, Mike Kravetz wrote:
> If an application would want to take advantage of this flag for tmpfs, it
> needs to map at a fixed address (MAP_FIXED) for huge page alignment.  So,
> it will need to do one of the 'mmap tricks' to get a mapping at a suitably
> aligned address.  

We don't need MAP_FIXED. We already have all required magic in
shmem_get_unmapped_area().

-- 
 Kirill A. Shutemov
