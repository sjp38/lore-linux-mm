Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1DC6B0184
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 07:52:07 -0400 (EDT)
Date: Tue, 21 Jun 2011 13:52:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 1/4] mm: completely disable THP by
 transparent_hugepage=0
Message-ID: <20110621115201.GD8093@tiehlicka.suse.cz>
References: <1308643849-3325-1-git-send-email-amwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308643849-3325-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Randy Dunlap <rdunlap@xenotime.net>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Tue 21-06-11 16:10:42, Amerigo Wang wrote:
> Introduce "transparent_hugepage=0" to totally disable THP.
> "transparent_hugepage=never" means setting THP to be partially
> disabled, we need a new way to totally disable it.

I am wondering why would you like to disable the feature on per-boot
basis. Does transparent_hugepage=never bring any measurable overhead?

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
