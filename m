Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2ECA6B0008
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 16:26:44 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f13-v6so1847824qtg.15
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 13:26:44 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id w131si2736923qkw.40.2018.04.18.13.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 13:26:43 -0700 (PDT)
Subject: Re: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and
 hugetlbfs
References: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <2804a1d0-9d68-ac43-3041-9490147b52b5@oracle.com>
Date: Wed, 18 Apr 2018 13:26:35 -0700
MIME-Version: 1.0
In-Reply-To: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, viro@zeniv.linux.org.uk, nyc@holomorphy.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/17/2018 02:08 PM, Yang Shi wrote:
> And, set the flag for hugetlbfs as well to keep the consistency, and the
> applications don't have to know what filesystem is used to use huge
> page, just need to check ST_HUGE flag.

For hugetlbfs, setting such a flag would be for consistency only.  mapping
hugetlbfs files REQUIRES huge page alignment and size.

If an application would want to take advantage of this flag for tmpfs, it
needs to map at a fixed address (MAP_FIXED) for huge page alignment.  So,
it will need to do one of the 'mmap tricks' to get a mapping at a suitably
aligned address.  

IIRC, there is code to 'suitably align' DAX mappings to appropriate huge page
boundaries.  Perhaps, something like this could be added for tmpfs mounted
with huge=?  Of course, this would not take into account 'length' but may
help some.

-- 
Mike Kravetz
