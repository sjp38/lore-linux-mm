Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A78846B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:49:14 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fy10so65851825pac.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:49:14 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id un7si51853122pac.228.2016.02.16.07.49.13
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 07:49:13 -0800 (PST)
Subject: Re: [PATCHv2 19/28] thp: run vma_adjust_trans_huge() outside
 i_mmap_rwsem
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-20-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56C344F7.8070107@intel.com>
Date: Tue, 16 Feb 2016 07:49:11 -0800
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

Ahhh, ... so we $SUBJECT in order to fix it.

Now it all makes sense.  Maybe I'm old fashioned, but I tend to have
forgotten $SUBJECT by the time I start to read the patch body text.
It's really handy for me when the body text stands on its own.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
