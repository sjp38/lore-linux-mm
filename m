Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5ED6B0038
	for <linux-mm@kvack.org>; Sun,  5 Mar 2017 21:18:33 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v190so56625562pfb.5
        for <linux-mm@kvack.org>; Sun, 05 Mar 2017 18:18:33 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p10si17527858pge.292.2017.03.05.18.18.32
        for <linux-mm@kvack.org>;
        Sun, 05 Mar 2017 18:18:32 -0800 (PST)
Date: Mon, 6 Mar 2017 11:18:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 11/11] mm: remove SWAP_[SUCCESS|AGAIN|FAIL]
Message-ID: <20170306021823.GF8779@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-12-git-send-email-minchan@kernel.org>
 <907b98e3-127a-4cad-deea-093785274b64@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <907b98e3-127a-4cad-deea-093785274b64@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On Fri, Mar 03, 2017 at 06:34:15PM +0530, Anshuman Khandual wrote:
> On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > There is no user for it. Remove it.
> 
> Last patches in the series prepared ground for this removal. The
> entire series looks pretty straight forward. As it does not change

Thanks.

> any functionality, wondering what kind of tests this should go
> through to look for any potential problems.

I don't think it can change something severe, either but one thing
I want to check is handling of mlocked pages part so I will do
some test for that.

Thanks for the review, Anshuman!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
