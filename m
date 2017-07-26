Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 932806B02B4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 08:47:08 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u89so31716076wrc.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 05:47:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 200si8843626wmf.64.2017.07.26.05.47.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 05:47:07 -0700 (PDT)
Date: Wed, 26 Jul 2017 14:47:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/hugetlb: Make huge_pte_offset() consistent and
 document behaviour
Message-ID: <20170726124704.GQ2981@dhcp22.suse.cz>
References: <20170725154114.24131-1-punit.agrawal@arm.com>
 <20170725154114.24131-2-punit.agrawal@arm.com>
 <20170726085038.GB2981@dhcp22.suse.cz>
 <20170726085325.GC2981@dhcp22.suse.cz>
 <87bmo7jt31.fsf@e105922-lin.cambridge.arm.com>
 <20170726123357.GP2981@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726123357.GP2981@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, steve.capper@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, kirill.shutemov@linux.intel.com, Mike Kravetz <mike.kravetz@oracle.com>

On Wed 26-07-17 14:33:57, Michal Hocko wrote:
> On Wed 26-07-17 13:11:46, Punit Agrawal wrote:
[...]
> > I've been running tests from mce-test suite and libhugetlbfs for similar
> > changes we did on arm64. There could be assumptions that were not
> > exercised but I'm not sure how to check for all the possible usages.
> > 
> > Do you have any other suggestions that can help improve confidence in
> > the patch?
> 
> Unfortunatelly I don't. I just know there were many subtle assumptions
> all over the place so I am rather careful to not touch the code unless
> really necessary.
> 
> That being said, I am not opposing your patch.

Let me be more specific. I am not opposing your patch but we should
definitely need more reviewers to have a look. I am not seeing any
immediate problems with it but I do not see a large improvements either
(slightly less nightmare doesn't make me sleep all that well ;)). So I
will leave the decisions to others.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
