Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 3DD056B005D
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 14:21:54 -0400 (EDT)
Message-ID: <50118182.8030308@redhat.com>
Date: Thu, 26 Jul 2012 13:42:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Larry Woodman <lwoodman@redhat.com>

On 07/23/2012 12:04 AM, Hugh Dickins wrote:

> Please don't be upset if I say that I don't like either of your patches.
> Mainly for obvious reasons - I don't like Mel's because anything with
> trylock retries and nested spinlocks worries me before I can even start
> to think about it; and I don't like Michal's for the same reason as Mel,
> that it spreads more change around in common paths than we would like.

I have a naive question.

In huge_pmd_share, we protect ourselves by taking
the mapping->i_mmap_mutex.

Is there any reason we could not take the i_mmap_mutex
in the huge_pmd_unshare path?

I see that hugetlb_change_protection already takes that
lock. Is there something preventing __unmap_hugepage_range
from also taking mapping->i_mmap_mutex?

That way the sharing and the unsharing code are
protected by the same, per shm segment, lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
