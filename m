Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7B496B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 03:56:05 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 140so1883358wmv.12
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:56:05 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id s15si20807732wjd.254.2016.10.25.00.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 00:56:04 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id h8so462163wmi.5
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:56:04 -0700 (PDT)
Date: Tue, 25 Oct 2016 09:56:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH stable 4.4 0/4] mm: workingset backports
Message-ID: <20161025075603.GB31137@dhcp22.suse.cz>
References: <20161025075148.31661-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025075148.31661-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Antonio SJ Musumeci <trapexit@spawn.link>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>

On Tue 25-10-16 09:51:44, Michal Hocko wrote:
> Hi,
> here is the backport of (hopefully) all workingset related fixes for
> 4.4 kernel. The series has been reviewed by Johannes [1]. The main
> motivation for the backport is 22f2ac51b6d6 ("mm: workingset: fix crash
> in shadow node shrinker caused by replace_page_cache_page()") which is
> a fix for a triggered BUG_ON. This is not sufficient because there are
> follow up fixes which were introduced later.
 
 Ups, forgot to add
[1] http://lkml.kernel.org/r/20161024152605.11707-1-mhocko@kernel.org

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
