Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A43FE6B0034
	for <linux-mm@kvack.org>; Thu,  9 May 2013 20:31:11 -0400 (EDT)
Date: Fri, 10 May 2013 04:24:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5 19/31] hugepage: convert huge zero page shrinker to
 new shrinker API
Message-ID: <20130510012458.GA3049@shutemov.name>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
 <1368079608-5611-20-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368079608-5611-20-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, May 09, 2013 at 10:06:36AM +0400, Glauber Costa wrote:
> It consists of:
> 
> * returning long instead of int
> * separating count from scan
> * returning the number of freed entities in scan
> 
> Signed-off-by: Glauber Costa <glommer@openvz.org>
> Reviewed-by: Greg Thelen <gthelen@google.com>
> CC: Dave Chinner <dchinner@redhat.com>
> CC: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
