Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 910B86B000E
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 17:48:35 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j21so134884wre.20
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 14:48:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i195si2482987wmd.142.2018.03.06.14.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 14:48:34 -0800 (PST)
Date: Tue, 6 Mar 2018 14:48:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 08/11] mm: Clear arch specific VM flags on
 protection change
Message-Id: <20180306144814.86eac0c28e98b50d550fc2fd@linux-foundation.org>
In-Reply-To: <f0bfc4b7ce6c8563bf0d5ef74af20b5d1edea66f.1519227112.git.khalid.aziz@oracle.com>
References: <cover.1519227112.git.khalid.aziz@oracle.com>
	<f0bfc4b7ce6c8563bf0d5ef74af20b5d1edea66f.1519227112.git.khalid.aziz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: davem@davemloft.net, dave.hansen@linux.intel.com, mhocko@suse.com, jack@suse.cz, kirill.shutemov@linux.intel.com, ross.zwisler@linux.intel.com, willy@infradead.org, hughd@google.com, n-horiguchi@ah.jp.nec.com, mgorman@suse.de, jglisse@redhat.com, dave.jiang@intel.com, dan.j.williams@intel.com, anthony.yznaga@oracle.com, nadav.amit@gmail.com, zi.yan@cs.rutgers.edu, aarcange@redhat.com, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, henry.willard@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On Wed, 21 Feb 2018 10:15:50 -0700 Khalid Aziz <khalid.aziz@oracle.com> wrote:

> When protection bits are changed on a VMA, some of the architecture
> specific flags should be cleared as well. An examples of this are the
> PKEY flags on x86. This patch expands the current code that clears
> PKEY flags for x86, to support similar functionality for other
> architectures as well.
> 
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Khalid Aziz <khalid@gonehiking.org>
> Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
