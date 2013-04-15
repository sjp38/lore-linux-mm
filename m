Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 36E6E6B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 03:17:43 -0400 (EDT)
Date: Mon, 15 Apr 2013 11:10:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3 19/32] hugepage: convert huge zero page shrinker to
 new shrinker API
Message-ID: <20130415081058.GA11428@shutemov.name>
References: <1365429659-22108-1-git-send-email-glommer@parallels.com>
 <1365429659-22108-20-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365429659-22108-20-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Dave Shrinnker <david@fromorbit.com>, Serge Hallyn <serge.hallyn@canonical.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On Mon, Apr 08, 2013 at 06:00:46PM +0400, Glauber Costa wrote:
> It consists of:
> 
> * returning long instead of int
> * separating count from scan
> * returning the number of freed entities in scan
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Dave Chinner <dchinner@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
