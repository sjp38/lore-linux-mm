Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75B9A6B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:29:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d5so3163169pfn.12
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:29:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si3340843pgc.267.2018.03.15.05.29.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 05:29:48 -0700 (PDT)
Date: Thu, 15 Mar 2018 13:29:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm] mm, madvise, THP: Use THP aligned address in
 madvise_free_huge_pmd()
Message-ID: <20180315122944.GH23100@dhcp22.suse.cz>
References: <20180315011840.27599-1-ying.huang@intel.com>
 <869F4AAA-5BBA-40D6-916F-6919E515D271@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <869F4AAA-5BBA-40D6-916F-6919E515D271@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@kernel.org>, jglisse@redhat.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Wed 14-03-18 21:39:54, Zi Yan wrote:
> This cannot happen.
> 
> Two address parameters are passed: addr and next.
> If a??addra?? is not aligned and a??nexta?? is aligned or the end of madvise range, which might not be aligned,
> either way next - addr < HPAGE_PMD_SIZE.
> 
> This means the code in a??if (next - addr != HPAGE_PMD_SIZE)a??, which is above your second hunk,
> will split the THP between a??addra?? and a??nexta?? and get out as long as a??addra?? is not aligned.
> Thus, the code in your second hunk should always get aligned a??addra??.

OK, so what would happen if the above doesn't hold anymore after some
change up the call chain? Is it critical? If yes, do we want VM_BUG_ON
to detect that? Or at least document the asumption?
-- 
Michal Hocko
SUSE Labs
