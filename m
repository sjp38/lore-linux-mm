Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4888F6B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:42:10 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id x65so51472007pfb.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:42:10 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id fg8si21430992pad.227.2016.02.12.10.42.09
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 10:42:09 -0800 (PST)
Subject: Re: [PATCHv2 17/28] thp: skip file huge pmd on copy_huge_pmd()
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-18-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56BE2781.7060808@intel.com>
Date: Fri, 12 Feb 2016 10:42:09 -0800
MIME-Version: 1.0
In-Reply-To: <1455200516-132137-18-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> File pmds can be safely skip on copy_huge_pmd(), we can re-fault them
> later. COW for file mappings handled on pte level.

Is this different from 4k pages?  I figured we might skip copying
file-backed ptes on fork, but I couldn't find the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
