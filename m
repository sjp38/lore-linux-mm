Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id A48E06B004D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 10:48:28 -0400 (EDT)
Date: Tue, 10 Sep 2013 15:48:24 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 9/9] prepare to remove
 /proc/sys/vm/hugepages_treat_as_movable
Message-ID: <20130910144823.GS22421@suse.de>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-10-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1376025702-14818-10-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 09, 2013 at 01:21:42AM -0400, Naoya Horiguchi wrote:
> Now we have extended hugepage migration and it's opened to many users
> of page migration, which is a good reason to consider hugepage as movable.
> So we can go to the direction to remove this parameter. In order to
> allow userspace to prepare for the removal, let's leave this sysctl handler
> as noop for a while.
> 

Note that this assumes that users interested in memory hot-remove and
hugepages are also willing to resize the hugepage pool on the target nodes
before attempting the hot-remove operation. I guess that technically the
necessary setup steps could be done from userspace or manually by the
system administrator but it may not be obvious to the system
administrator that the step is required.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
