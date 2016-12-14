Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 795EC6B0253
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 16:16:09 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so3233145wme.5
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 13:16:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cv5si56202952wjc.141.2016.12.14.13.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 13:16:08 -0800 (PST)
Date: Wed, 14 Dec 2016 16:15:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] tmpfs: change shmem_mapping() to test shmem_aops
Message-ID: <20161214211552.GA1796@cmpxchg.org>
References: <alpine.LSU.2.11.1612052148530.13021@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1612052148530.13021@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org

On Mon, Dec 05, 2016 at 09:52:36PM -0800, Hugh Dickins wrote:
> Callers of shmem_mapping() are interested in whether the mapping is
> swap backed - except for uprobes, which is interested in whether it
> should use shmem_read_mapping_page().  All these callers are better
> served by a shmem_mapping() which checks for shmem_aops, than the
> current version which goes through several indirections to find where
> the inode lives - and has the surprising effect that a private mmap of
> /dev/zero satisfies both vma_is_anonymous() and shmem_mapping(), when
> that device node is on devtmpfs.  I don't think anything in the tree
> suffers from that surprise, but it caught me out, and is better fixed.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

There are actually some existing sites that check for shmemness this
way. Do you see value in converting them?

---
