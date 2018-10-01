Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id D90376B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 13:21:36 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id e197-v6so4810368ita.9
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 10:21:36 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d71-v6si8836736iof.257.2018.10.01.10.21.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 10:21:35 -0700 (PDT)
Date: Mon, 1 Oct 2018 10:21:18 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V5 RESEND 03/21] swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20181001172118.5kutcg33v7ipje2q@ca-dmjordan1.us.oracle.com>
References: <20180925071348.31458-1-ying.huang@intel.com>
 <20180925071348.31458-4-ying.huang@intel.com>
 <20180925191953.4ped5ki7u3ymafmd@ca-dmjordan1.us.oracle.com>
 <874lecifj4.fsf@yhuang-dev.intel.com>
 <20180926145145.6xp2kxpngyd54f6i@ca-dmjordan1.us.oracle.com>
 <87r2hfhger.fsf@yhuang-dev.intel.com>
 <20180927211238.ly3e7cyvfu3rswcv@ca-dmjordan1.us.oracle.com>
 <87lg7mf30o.fsf@yhuang-dev.intel.com>
 <20180928213224.tjff2rtfmxmnz5nq@ca-dmjordan1.us.oracle.com>
 <877ej5f7oq.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877ej5f7oq.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Sat, Sep 29, 2018 at 08:50:29AM +0800, Huang, Ying wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> > The error handling in __swap_duplicate (before this series) still leaves
> > something to be desired IMHO.  Why all the different returns when callers
> > ignore them or only specifically check for -ENOMEM or -EEXIST?  Could maybe
> > stand a cleanup, but outside this series.
> 
> Yes.  Maybe.  I guess you will work on this?

Sure, I'll see how it turns out.
