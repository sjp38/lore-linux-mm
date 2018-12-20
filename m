Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 771DB8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 10:37:37 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t2so2675562edb.22
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 07:37:37 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id u12si2465223edq.37.2018.12.20.07.37.36
        for <linux-mm@kvack.org>;
        Thu, 20 Dec 2018 07:37:36 -0800 (PST)
Date: Thu, 20 Dec 2018 16:37:34 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220153731.mpc757cyf2zyr6fm@d104.suse.de>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
 <20181220091228.GB14234@dhcp22.suse.cz>
 <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
 <20181220130606.GG9104@dhcp22.suse.cz>
 <20181220134132.6ynretwlndmyupml@d104.suse.de>
 <20181220142124.r34fnuv6b33luj5a@d104.suse.de>
 <20181220143939.GA6210@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220143939.GA6210@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 03:39:39PM +0100, Michal Hocko wrote:
> Yes, you are missing that this code should be as sane as possible ;) You
> are right that we are only processing one pageorder worth of pfns and
> that the page order is bound to HUGETLB_PAGE_ORDER _right_now_. But
> there is absolutely zero reason to hardcode that assumption into a
> simple loop, right?

Of course, it makes sense to keep the code as sane as possible.
This is why I said I was not against the change, but I wanted to
see if I was missing something else besides the assumption.

Thanks
-- 
Oscar Salvador
SUSE L3
