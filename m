Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF93A6B0005
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 23:01:15 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id o6-v6so28013854oib.9
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 20:01:15 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m12si14417049otb.186.2018.10.21.20.01.14
        for <linux-mm@kvack.org>;
        Sun, 21 Oct 2018 20:01:14 -0700 (PDT)
Subject: Re: [PATCH V2 1/5] mm/hugetlb: Enable PUD level huge page migration
References: <1539316799-6064-1-git-send-email-anshuman.khandual@arm.com>
 <1539316799-6064-2-git-send-email-anshuman.khandual@arm.com>
 <20181019080959.GL18839@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <7d32fcdc-1ee3-7666-3b33-eda14ca8b380@arm.com>
Date: Mon, 22 Oct 2018 08:31:05 +0530
MIME-Version: 1.0
In-Reply-To: <20181019080959.GL18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 10/19/2018 01:39 PM, Michal Hocko wrote:
> I planed to get to review this earlier but been busy. Anyway, this patch
> should be applied only after movability one to prevent from
> (theoretical) bisectability issues.

Sure, I can change the order there.

> 
> I would probably fold it into the one which defines arch specific hook.

Hmm but that may be like doing two functionality changes together. Adding one
more conditional check and at the same time wrapping it over with a new name
which is part of a new scheme. I would suggest keeping the patches separate.
