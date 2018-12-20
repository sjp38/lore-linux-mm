Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E58B8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 15:31:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so3552854ede.19
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:31:31 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id t3-v6si2031911ejx.136.2018.12.20.12.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 12:31:30 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 6C7461C2CFE
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 20:31:29 +0000 (GMT)
Date: Thu, 20 Dec 2018 20:31:27 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 06/14] mm, migrate: Immediately fail migration of a page
 with no migration handler
Message-ID: <20181220203127.GB31517@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-7-mgorman@techsingularity.net>
 <CAHbLzko6jXSikw-4LQXi6KfNR9=U4XJnB_OaaZ4XcNHUj4NLUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAHbLzko6jXSikw-4LQXi6KfNR9=U4XJnB_OaaZ4XcNHUj4NLUQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 20, 2018 at 11:44:57AM -0800, Yang Shi wrote:
> On Fri, Dec 14, 2018 at 3:03 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > Pages with no migration handler use a fallback hander which sometimes
> > works and sometimes persistently fails such as blockdev pages. Migration
> 
> A minor correction. The above statement sounds not accurate anymore
> since Jan Kara had patch series (blkdev: avoid migration stalls for
> blkdev pages) have blockdev use its own migration handler.
> 

I'm aware given that I reviewed that series. The statement was correct
at the time of writing. I'll alter the example when rebased on top of
Jan's work.

-- 
Mel Gorman
SUSE Labs
