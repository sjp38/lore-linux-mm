Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1CBF2280300
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 11:46:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f4so4326370wmh.7
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 08:46:55 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d21sor291080edb.24.2017.09.05.08.46.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Sep 2017 08:46:53 -0700 (PDT)
Date: Tue, 5 Sep 2017 18:46:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Fix mem_cgroup_oom_disable() call missing
Message-ID: <20170905154650.c3xiwp52btcckjr4@node.shutemov.name>
References: <1504625439-31313-1-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1504625439-31313-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue, Sep 05, 2017 at 05:30:39PM +0200, Laurent Dufour wrote:
> Seen while reading the code, in handle_mm_fault(), in the case
> arch_vma_access_permitted() is failing the call to mem_cgroup_oom_disable()
> is not made.
> 
> To fix that, move the call to mem_cgroup_oom_enable() after calling
> arch_vma_access_permitted() as it should not have entered the memcg OOM.
> 
> Fixes: bae473a423f6 ("mm: introduce fault_env")
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Ouch. Sorry for this.

Acked-by: Kirill A. Shutemov <kirill@shutemov.name>

Cc: stable@ is needed too.

It's strange we haven't seen reports of warning from
mem_cgroup_oom_enable().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
