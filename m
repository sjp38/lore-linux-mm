Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC4E6B0038
	for <linux-mm@kvack.org>; Mon, 12 May 2014 12:07:16 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id x13so8103331qcv.33
        for <linux-mm@kvack.org>; Mon, 12 May 2014 09:07:15 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id x7si6230910qaj.117.2014.05.12.09.07.15
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 09:07:15 -0700 (PDT)
Date: Mon, 12 May 2014 11:07:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: add comment for __mod_zone_page_stat
In-Reply-To: <CAHz2CGUfLx7DNgdNoAL0G3a9Ht6yf3bhWaojjNx91aF7L-iDQw@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1405121106080.17673@gentwo.org>
References: <1399811500-14472-1-git-send-email-nasa4836@gmail.com> <alpine.DEB.2.10.1405120858040.3090@gentwo.org> <CAHz2CGUfLx7DNgdNoAL0G3a9Ht6yf3bhWaojjNx91aF7L-iDQw@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, fabf@skynet.be, sasha.levin@oracle.com, oleg@redhat.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, iamjoonsoo.kim@lge.com, kirill.shutemov@linux.intel.com, Cyrill Gorcunov <gorcunov@gmail.com>, dave.hansen@linux.intel.com, toshi.kani@hp.com, paul.gortmaker@windriver.com, srivatsa.bhat@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 12 May 2014, Jianyu Zhan wrote:

> This means they guarantee that even they are preemted the vm
> counter won't be modified incorrectly.  Because the counter is page-related
> (e.g., a new anon page added), and they are exclusively hold the pte lock.

Ok. if these locations hold the pte lock then preemption is disabled and
you are ok to use __mod_zone_page_state. Has nothing to do with the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
