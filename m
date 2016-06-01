Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3266D6B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 18:34:44 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fg1so22996552pad.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 15:34:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i184si45663931pfc.224.2016.06.01.15.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 15:34:43 -0700 (PDT)
Date: Wed, 1 Jun 2016 15:34:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/4] mm/hugetlb: Simplify hugetlb unmap
Message-Id: <20160601153442.229f0747c97d1bbf21f1a935@linux-foundation.org>
In-Reply-To: <1464587062-17745-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1464587062-17745-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 30 May 2016 11:14:19 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> For hugetlb like THP (and unlike regular page), we do tlb flush after
> dropping ptl. Because of the above, we don't need to track force_flush
> like we do now. Instead we can simply call tlb_remove_page() which
> will do the flush if needed.
> 
> No functionality change in this patch.

This all looks fairly non-horrifying.  Will a non-RFC version be
forthcoming?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
