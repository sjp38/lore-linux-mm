Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 941BD6B0256
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 05:17:00 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so102340727pac.2
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 02:17:00 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id wf1si50219467pab.219.2016.02.16.02.16.59
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 02:17:00 -0800 (PST)
Date: Tue, 16 Feb 2016 13:16:42 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 19/28] thp: run vma_adjust_trans_huge() outside
 i_mmap_rwsem
Message-ID: <20160216101642.GG46557@black.fi.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-20-git-send-email-kirill.shutemov@linux.intel.com>
 <56BE295A.6060209@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56BE295A.6060209@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Feb 12, 2016 at 10:50:02AM -0800, Dave Hansen wrote:
> On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> > vma_addjust_trans_huge() splits pmd if it's crossing VMA boundary.
> > During split we munlock the huge page which requires rmap walk.
> > rmap wants to take the lock on its own.
> 
> Which lock are you talking about here?

i_mmap_rwsem. It's in patch subject. I'll update body.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
