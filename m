Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 13A036B006E
	for <linux-mm@kvack.org>; Wed,  4 Feb 2015 07:52:23 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so3372561wib.5
        for <linux-mm@kvack.org>; Wed, 04 Feb 2015 04:52:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5si3915264wic.61.2015.02.04.04.52.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Feb 2015 04:52:21 -0800 (PST)
Date: Wed, 4 Feb 2015 13:52:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20150204125218.GE29434@dhcp22.suse.cz>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
 <1413799924-17946-2-git-send-email-minchan@kernel.org>
 <20141127144725.GB19157@dhcp22.suse.cz>
 <20141130235652.GA10333@bbox>
 <20141202100125.GD27014@dhcp22.suse.cz>
 <20141203000026.GA30217@bbox>
 <20141203101329.GB23236@dhcp22.suse.cz>
 <20141205070816.GB3358@bbox>
 <20141205083249.GA2321@dhcp22.suse.cz>
 <54D0F9BC.4060306@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54D0F9BC.4060306@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 03-02-15 17:39:24, Michael Kerrisk wrote:
[...]
> If I'm reading the conversation right, the initially proposed text 
> was from the BSD man page (which would be okay), but most of the 
> text above seems  to have come straight from the page here:
> http://www.lehman.cuny.edu/cgi-bin/man-cgi?madvise+3
> 
> Right?
> 
> Unfortunately, I don't think we can use that text. It's from the 
> Solaris man page as far as I can tell, and I doubt that it's 
> under a license that we can use.

Ohh, I wasn't aware of that restriction and didn't notice anything at
the man page nor http://www.lehman.cuny.edu/cgi-bin/man-cgi.
But you are definitely right that it would be better to not use this
source. Sorry about that, I should have noticed that myself.

> If that's the case, we need to go back and come up with an
> original text. It might draw inspiration from the Solaris page,
> and take actual text from the BSD page (which is under a free
> license), and it might also draw inspiration from Jon Corbet's 
> description at http://lwn.net/Articles/590991/. 
> 
> Could you take another shot this please!

Minchan is obviously working on one and I will review it once he is done
with it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
