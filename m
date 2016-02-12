Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1BAA76B0253
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:50:03 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so51537937pfb.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:50:03 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id lm9si21475515pab.142.2016.02.12.10.50.02
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 10:50:02 -0800 (PST)
Subject: Re: [PATCHv2 19/28] thp: run vma_adjust_trans_huge() outside
 i_mmap_rwsem
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-20-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56BE295A.6060209@intel.com>
Date: Fri, 12 Feb 2016 10:50:02 -0800
MIME-Version: 1.0
In-Reply-To: <1455200516-132137-20-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> vma_addjust_trans_huge() splits pmd if it's crossing VMA boundary.
> During split we munlock the huge page which requires rmap walk.
> rmap wants to take the lock on its own.

Which lock are you talking about here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
