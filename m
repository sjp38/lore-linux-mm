Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C855B6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:34:11 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k62so2211425qkl.15
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:34:11 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id m76si760865qkh.259.2016.10.26.02.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 02:34:11 -0700 (PDT)
Date: Wed, 26 Oct 2016 11:34:19 +0200
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH stable 4.4 0/4] mm: workingset backports
Message-ID: <20161026093419.GA4974@kroah.com>
References: <20161025075148.31661-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025075148.31661-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Antonio SJ Musumeci <trapexit@spawn.link>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Miklos Szeredi <miklos@szeredi.hu>

On Tue, Oct 25, 2016 at 09:51:44AM +0200, Michal Hocko wrote:
> Hi,
> here is the backport of (hopefully) all workingset related fixes for
> 4.4 kernel. The series has been reviewed by Johannes [1]. The main
> motivation for the backport is 22f2ac51b6d6 ("mm: workingset: fix crash
> in shadow node shrinker caused by replace_page_cache_page()") which is
> a fix for a triggered BUG_ON. This is not sufficient because there are
> follow up fixes which were introduced later.

Thanks for these, all now queued up.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
