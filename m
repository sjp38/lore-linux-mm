Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B49C6B0279
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 05:25:28 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so54357251lfb.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:25:27 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id a207si3129106lfd.240.2016.09.23.02.25.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 02:25:26 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id s29so5368434lfg.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 02:25:26 -0700 (PDT)
Date: Fri, 23 Sep 2016 12:25:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] huge tmpfs: fix Committed_AS leak
Message-ID: <20160923092523.GA29313@node.shutemov.name>
References: <alpine.LSU.2.11.1609221034040.17333@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1609221034040.17333@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 22, 2016 at 10:37:03AM -0700, Hugh Dickins wrote:
> Under swapping load on huge tmpfs, /proc/meminfo's Committed_AS grows
> bigger and bigger: just a cosmetic issue for most users, but disabling
> for those who run without overcommit (/proc/sys/vm/overcommit_memory 2).
> 
> shmem_uncharge() was forgetting to unaccount __vm_enough_memory's charge,
> and shmem_charge() was forgetting it on the filesystem-full error path.
> 
> Fixes: 800d8c63b2e9 ("shmem: add huge pages support")
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
