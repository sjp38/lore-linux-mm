Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B23CC6B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 07:28:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e7-v6so2966473edb.23
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 04:28:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13-v6si1094624edl.365.2018.10.03.04.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 04:28:00 -0700 (PDT)
Date: Wed, 3 Oct 2018 13:27:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
Message-ID: <20181003112758.GC4714@dhcp22.suse.cz>
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
 <835085a2-79c2-4eb5-2c10-13bb2893f611@arm.com>
 <c0689b0c-4810-e0e8-354e-55c45d59b6d0@arm.com>
 <a6b96126-5571-2aa2-6deb-09a457afd781@arm.com>
 <bad51030-5f02-4fc9-741c-0fffbd690aca@arm.com>
 <789784ee-4830-753b-5d14-f5c7d90622c4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <789784ee-4830-753b-5d14-f5c7d90622c4@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suzuki K Poulose <suzuki.poulose@arm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Wed 03-10-18 12:17:52, Suzuki K Poulose wrote:
[...]
> I have been under the idea that all the checks at the same level could
> have the same indentation. (i.e, 2 tabs in this case for each). Looks
> like there is no rule about it. How about replacing it with a
> switch..case  ?

I would simply follow the existing indentation style in that function.
Is this really worth discussig, anyway? Does the proposed change makes
the code harder to read?

-- 
Michal Hocko
SUSE Labs
