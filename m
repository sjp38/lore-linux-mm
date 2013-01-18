Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 18F146B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 08:58:33 -0500 (EST)
Date: Fri, 18 Jan 2013 14:58:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memory-hotplug: mm/Kconfig: move auto selects from
 MEMORY_HOTPLUG to MEMORY_HOTREMOVE as needed
Message-ID: <20130118135828.GD10701@dhcp22.suse.cz>
References: <1358495676-4488-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358495676-4488-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, laijs@cn.fujitsu.com

On Fri 18-01-13 15:54:36, Lin Feng wrote:
> Besides page_isolation.c selected by MEMORY_ISOLATION under MEMORY_HOTPLUG
> is also such case, move it too.

Yes, it seems that only HOTREMOVE needs MEMORY_ISOLATION but that should
be done in a separate patch as this change is already upstream and
should be merged separately. It would also be nice to mention which
functions are we talking about. AFAICS:
alloc_migrate_target, test_pages_isolated, start_isolate_page_range and
undo_isolate_page_range.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
