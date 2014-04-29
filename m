Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id C80806B004D
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 15:27:45 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id q108so771963qgd.17
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 12:27:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a1si10026044qar.51.2014.04.29.12.27.44
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 12:27:45 -0700 (PDT)
From: n-horiguchi@ah.jp.nec.com
Subject: Re: [PATCH] mm,numa: remove BUG_ON in __handle_mm_fault
Date: Tue, 29 Apr 2014 15:26:22 -0400
Message-Id: <535ffd31.c177e00a.701c.ffffe36bSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140425144147.679a7608@annuminas.surriel.com>
References: <20140425144147.679a7608@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, peterz@infradead.org, mgorman@suse.de, dave.hansen@intel.com, sunil.k.pandey@intel.com

On Fri, Apr 25, 2014 at 02:41:47PM -0400, Rik van Riel wrote:
> Changing PTEs and PMDs to pte_numa & pmd_numa is done with the
> mmap_sem held for reading, which means a pmd can be instantiated
> and/or turned into a numa one while __handle_mm_fault is examining
> the value of orig_pmd.
> 
> If that happens, __handle_mm_fault should just return and let
> the page fault retry, instead of throwing an oops.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Reported-by: Sunil Pandey <sunil.k.pandey@intel.com>

Looks good to me.
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
