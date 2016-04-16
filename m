Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D75C6B0005
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 00:55:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so222338132pfe.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 21:55:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kq10si1143505pab.242.2016.04.15.21.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 21:55:20 -0700 (PDT)
Date: Fri, 15 Apr 2016 21:55:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/10] huge pagecache: mmap_sem is unlocked when
 truncation splits pmd
Message-Id: <20160415215519.98f179c7418d4d2e9b316240@linux-foundation.org>
In-Reply-To: <20160414173922.GE3120@linux.intel.com>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
	<alpine.LSU.2.11.1604051352540.5965@eggly.anvils>
	<20160414173922.GE3120@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 14 Apr 2016 13:39:22 -0400 Matthew Wilcox <willy@linux.intel.com> wrote:

> On Tue, Apr 05, 2016 at 01:55:23PM -0700, Hugh Dickins wrote:
> > zap_pmd_range()'s CONFIG_DEBUG_VM !rwsem_is_locked(&mmap_sem) BUG()
> > will be invalid with huge pagecache, in whatever way it is implemented:
> > truncation of a hugely-mapped file to an unhugely-aligned size would
> > easily hit it.
> 
> We can reproduce this BUG() in the current Linus tree with DAX PMDs.
> Andrew, can you send this patch to Linus for inclusion in 4.7?

Wilco, thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
