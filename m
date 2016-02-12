Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id BF74F6B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:36:26 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id x65so51404541pfb.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:36:26 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id i26si21429649pfi.132.2016.02.12.10.36.26
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 10:36:26 -0800 (PST)
Subject: Re: [PATCHv2 15/28] thp: handle file COW faults
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-16-git-send-email-kirill.shutemov@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56BE2629.90001@intel.com>
Date: Fri, 12 Feb 2016 10:36:25 -0800
MIME-Version: 1.0
In-Reply-To: <1455200516-132137-16-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/11/2016 06:21 AM, Kirill A. Shutemov wrote:
> File COW for THP is handled on pte level: just split the pmd.

More changelog.  More comments, please.

We don't want to COW THP's because we'll waste memory?  A COW that we
could handle with 4k, we would have to handle with 2M, and that's
inefficient and high-latency?

Seems like a good idea to me.  It would just be nice to ensure every
reviewer doesn't have to think their way through it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
