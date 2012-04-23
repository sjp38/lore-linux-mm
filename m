Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 942516B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 12:49:09 -0400 (EDT)
Message-ID: <4F9587E3.6090802@redhat.com>
Date: Mon, 23 Apr 2012 12:48:35 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
References: <1334356721-9009-1-git-send-email-yinghan@google.com> <20120420151143.433c514e.akpm@linux-foundation.org> <4F93D0D9.3050901@redhat.com> <CALWz4izsOs_-gjR7VV7CyFpzqTQB7sTB4jr7WFBDUXLodZA5yQ@mail.gmail.com>
In-Reply-To: <CALWz4izsOs_-gjR7VV7CyFpzqTQB7sTB4jr7WFBDUXLodZA5yQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>

On 04/23/2012 12:40 PM, Ying Han wrote:

> Avi, does this patch help the case as you mentioned above, where kvm
> module is loaded but no virtual machines are present ? Why we have to
> walk the empty while holding the spinlock?

It might help marginally, but rather than defending
the patch, it might be more useful to try finding a
solution to the problem Mike and Eric are triggering.

How can we prevent the code from taking the lock and
throwing out EPT/NPT pages when there is no real need
to, and they will be faulted back in soon anyway?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
