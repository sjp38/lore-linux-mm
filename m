Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id EAC026B006E
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 13:32:45 -0500 (EST)
Received: by pdjg10 with SMTP id g10so10175111pdj.1
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 10:32:45 -0800 (PST)
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com. [209.85.192.169])
        by mx.google.com with ESMTPS id of5si11247191pdb.132.2015.02.06.10.32.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Feb 2015 10:32:45 -0800 (PST)
Received: by pdjg10 with SMTP id g10so10175037pdj.1
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 10:32:44 -0800 (PST)
Date: Fri, 6 Feb 2015 10:32:42 -0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20150206183242.GB2290@kernel.org>
References: <20141130235652.GA10333@bbox>
 <20141202100125.GD27014@dhcp22.suse.cz>
 <20141203000026.GA30217@bbox>
 <20141203101329.GB23236@dhcp22.suse.cz>
 <20141205070816.GB3358@bbox>
 <20141205083249.GA2321@dhcp22.suse.cz>
 <54D0F9BC.4060306@gmail.com>
 <20150203234722.GB3583@blaptop>
 <20150206003311.GA2347@kernel.org>
 <20150206125825.GA4498@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150206125825.GA4498@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Feb 06, 2015 at 01:58:25PM +0100, Michal Hocko wrote:
> On Thu 05-02-15 16:33:11, Shaohua Li wrote:
> [...]
> > Did you think about move the MADV_FREE pages to the head of inactive LRU, so
> > they can be reclaimed easily?
> 
> Yes this makes sense for pages living on the active LRU list. I would
> preserve LRU ordering on the inactive list because there is no good
> reason to make the operation more costly for inactive pages. On the
> other hand having tons of to-be-freed pages on the active list clearly
> sucks. Care to send a patch?

Considering anon pages are in active LRU first, it's likely MADV_FREE pages are
in active list. I'm curious why preserves the order of inactive list. App knows
which pages are cold, why don't take the advantages? I'll play the patch more
to see what I can do for it.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
