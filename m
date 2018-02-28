Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD2A6B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 05:58:17 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 5so1450689wrb.15
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 02:58:17 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a18sor942879edj.55.2018.02.28.02.58.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Feb 2018 02:58:15 -0800 (PST)
Date: Wed, 28 Feb 2018 13:58:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] selftests/vm: Update max va test to check for high
 address return.
Message-ID: <20180228105804.2uhjcfxu6zebkixh@node.shutemov.name>
References: <20180228035830.10089-1-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180228035830.10089-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Wed, Feb 28, 2018 at 09:28:30AM +0530, Aneesh Kumar K.V wrote:
> mmap(-1,..) is expected to search from max supported VA top down. It should find
> an address above ADDR_SWITCH_HINT. Explicitly check for this.

Hm. I don't think this correct. -1 means the application supports any
address, not restricted to 47-bit address space. It doesn't mean the
application *require* the address to be above 47-bit.

At least on x86, -1 just shift upper boundary of address range where we
can look for unmapped area.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
