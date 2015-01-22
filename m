Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 52B106B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 15:08:39 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id ft15so3628035pdb.5
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 12:08:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c14si1862660pdl.102.2015.01.22.12.08.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 12:08:38 -0800 (PST)
Date: Thu, 22 Jan 2015 12:08:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: pagewalk: call pte_hole() for VM_PFNMAP during
 walk_page_range
Message-Id: <20150122120820.8c279cf8.akpm@linux-foundation.org>
In-Reply-To: <1421820793-28883-1-git-send-email-shashim@codeaurora.org>
References: <1421820793-28883-1-git-send-email-shashim@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shiraz Hashim <shashim@codeaurora.org>
Cc: linux-mm@kvack.org, oleg@redhat.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, n-horiguchi@ah.jp.nec.com

On Wed, 21 Jan 2015 11:43:13 +0530 Shiraz Hashim <shashim@codeaurora.org> wrote:

> walk_page_range silently skips vma having VM_PFNMAP set,
> which leads to undesirable behaviour at client end (who
> called walk_page_range). For example for pagemap_read,
> when no callbacks are called against VM_PFNMAP vma,
> pagemap_read may prepare pagemap data for next virtual
> address range at wrong index.

This changelog doesn't have enough information for me to be able to
work out whether a -stable backport is needed.  Please always describe
the user-visible effects of a bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
