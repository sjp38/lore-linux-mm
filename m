Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B475A6B0010
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 03:16:27 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h48-v6so23828901edh.22
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 00:16:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p29-v6si1860593eda.132.2018.10.22.00.16.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 00:16:26 -0700 (PDT)
Date: Mon, 22 Oct 2018 09:16:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 1/5] mm/hugetlb: Enable PUD level huge page migration
Message-ID: <20181022071625.GS18839@dhcp22.suse.cz>
References: <1539316799-6064-1-git-send-email-anshuman.khandual@arm.com>
 <1539316799-6064-2-git-send-email-anshuman.khandual@arm.com>
 <20181019080959.GL18839@dhcp22.suse.cz>
 <7d32fcdc-1ee3-7666-3b33-eda14ca8b380@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7d32fcdc-1ee3-7666-3b33-eda14ca8b380@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Mon 22-10-18 08:31:05, Anshuman Khandual wrote:
> On 10/19/2018 01:39 PM, Michal Hocko wrote:
> > I would probably fold it into the one which defines arch specific hook.
> 
> Hmm but that may be like doing two functionality changes together. Adding one
> more conditional check and at the same time wrapping it over with a new name
> which is part of a new scheme. I would suggest keeping the patches separate.

I will surely not insist. If you think it is better this way then no
objections from me of course.

-- 
Michal Hocko
SUSE Labs
