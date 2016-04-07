Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BD0C16B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 04:28:45 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id zm5so50759432pac.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 01:28:45 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id kq10si10211628pab.242.2016.04.07.01.28.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 01:28:45 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id q129so6556038pfb.3
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 01:28:44 -0700 (PDT)
Subject: Re: [PATCH 01/10] mm/mmap: Replace SHM_HUGE_MASK with MAP_HUGE_MASK
 inside mmap_pgoff
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1460007464-26726-2-git-send-email-khandual@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <57061A34.6090301@gmail.com>
Date: Thu, 7 Apr 2016 18:28:36 +1000
MIME-Version: 1.0
In-Reply-To: <1460007464-26726-2-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au



On 07/04/16 15:37, Anshuman Khandual wrote:
> The commit 091d0d55b286 ("shm: fix null pointer deref when userspace
> specifies invalid hugepage size") had replaced MAP_HUGE_MASK with
> SHM_HUGE_MASK. Though both of them contain the same numeric value of
> 0x3f, MAP_HUGE_MASK flag sounds more appropriate than the other one
> in the context. Hence change it back.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
