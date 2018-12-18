Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1378E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 07:21:09 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so12279973edb.22
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:21:09 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id 93si1768174ede.376.2018.12.18.04.21.07
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 04:21:08 -0800 (PST)
Date: Tue, 18 Dec 2018 13:21:07 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH] mm: do not report isolation failures for CMA pages
Message-ID: <20181218122107.vyvkxa5xg4hhfhtb@d104.suse.de>
References: <20181218092802.31429-1-mhocko@kernel.org>
 <20181218101831.ma3j5llxcsthibop@d104.suse.de>
 <20181218112822.GG30879@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218112822.GG30879@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 18, 2018 at 12:28:22PM +0100, Michal Hocko wrote:
> Well, I haven't seen any reports about hugetlb pages so I didn't bother
> to mention it. Is this really important to note?

I guess not.

> 
> > "Only report isolation failures from memhotplug code" ?
> 
> only report isolation failures when offlining memory

Yes, that looks good.
-- 
Oscar Salvador
SUSE L3
