Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 31FAE6B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:49:20 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id c10so52326398pfc.2
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:49:20 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id m80si21454195pfi.252.2016.02.12.10.49.19
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 10:49:19 -0800 (PST)
Subject: Re: [PATCHv2 18/28] thp: prepare change_huge_pmd() for file thp
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-19-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56BE291B.3080808@intel.com>
Date: Fri, 12 Feb 2016 10:48:59 -0800
MIME-Version: 1.0
In-Reply-To: <1455200516-132137-19-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> change_huge_pmd() has assert which is not relvant for file page.
> For shared mapping it's perfectly fine to have page table entry
> writable, without explicit mkwrite.

Should we have the bug only trigger on anonymous VMAs instead of
removing it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
