Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id B1AE36B00B6
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 05:55:53 -0400 (EDT)
Date: Wed, 20 Jun 2012 17:55:46 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120620095546.GB8765@localhost>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
 <20120619150014.1ebc108c.akpm@linux-foundation.org>
 <20120620092011.GB4011@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120620092011.GB4011@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

> > Finally, I wonder if there should be some timeout of that wait.  I
> > don't know why, but I wouldn't be surprised if we hit some glitch which
> > causes us to add one!
> > 
> 
> If we hit such a situation it means that flush is no longer working which
> is interesting in itself. I guess one possibility where it can occur is
> if we hit global dirty limits (or memcg dirty limits when they exist)
> and the page is backed by NFS that is disconnected. That would stall here
> potentially forever but it's already the case that a system that hits its
> dirty limits with a disconnected NFS is in trouble and a timeout here will
> not do much to help.

Agreed. I've run into such cases and cannot login even locally because
the shell will be blocked trying to write even 1 byte at startup time. 
Any opened shells are also stalled on writing to .bash_history etc.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
