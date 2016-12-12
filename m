Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD93A6B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 16:01:21 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so17531871wmw.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 13:01:21 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id hi2si46420382wjc.63.2016.12.12.13.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 13:01:20 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id m203so13798392wma.3
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 13:01:20 -0800 (PST)
Date: Tue, 13 Dec 2016 00:01:18 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm/thp/pagecache: Only withdraw page table after a
 successful deposit
Message-ID: <20161212210118.GB10202@node.shutemov.name>
References: <20161212163428.6780-1-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161212163428.6780-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 12, 2016 at 10:04:27PM +0530, Aneesh Kumar K.V wrote:
> The current code wrongly called withdraw in the error path. But we
> haven't depoisted the page table yet in the only error path in that
> function. So for now remove that withdraw completely. If we take
> that "out:" branch, we should have vmf->prealloc_pte already pointing
> to the allocated page table.
> 
> Fixes: "mm: THP page cache support for ppc64"
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
