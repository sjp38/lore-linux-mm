Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A29BC6B026D
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:30:05 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so7434587pac.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:30:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fo3si2409372pad.17.2015.07.14.08.30.04
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 08:30:04 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <55A4D110.2070103@redhat.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
 <55A4D110.2070103@redhat.com>
Subject: Re: [PATCH 00/36] THP refcounting redesign
Content-Transfer-Encoding: 7bit
Message-Id: <20150714152929.141F2118@black.fi.intel.com>
Date: Tue, 14 Jul 2015 18:29:29 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Jerome Marchand wrote:
> On 07/10/2015 07:41 PM, Kirill A. Shutemov wrote:
> > Hello everybody,
> > 
> ...
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcounting/v5
> > 
> 
> I guess you mean thp/refcounting/v8.

Right.

> Also you might want to add v8 to the subject.

Yeah, sorry.

> Still on the cosmetic side, checkpatch.pl show quite a few
> coding style errors and warnings. You'll make maintainer life easier by
> running checkpatch on your serie.

I've sent fixlets which addresses checkpach complains.

I didn't fix warnings

"WARNING: Missing a blank line after declarations"

I'm not convinced fixing them make any good, but I can if Andrew thinks it's
beneficial.

I've updated the branch with checkpatch fixes.

> On the content side: I've quickly tested this version without finding
> any issue so far.
> 
> Thanks,
> Jerome
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
