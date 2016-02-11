Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB7D6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 13:52:11 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id c10so34158762pfc.2
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 10:52:11 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id l84si14117856pfb.158.2016.02.11.10.52.10
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 10:52:10 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCHv2 02/28] rmap: introduce rmap_walk_locked()
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1455200516-132137-3-git-send-email-kirill.shutemov@linux.intel.com>
Date: Thu, 11 Feb 2016 10:52:08 -0800
In-Reply-To: <1455200516-132137-3-git-send-email-kirill.shutemov@linux.intel.com>
	(Kirill A. Shutemov's message of "Thu, 11 Feb 2016 17:21:30 +0300")
Message-ID: <87y4ardqqv.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> rmap_walk_locked() is the same as rmap_walk(), but caller takes care
> about relevant rmap lock.
>
> It's preparation to switch THP splitting from custom rmap walk in
> freeze_page()/unfreeze_page() to generic one.

Would be better to move all locking into the callers, with an
appropiate helper for users who don't want to deal with it.
Conditional locking based on flags is always tricky.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
