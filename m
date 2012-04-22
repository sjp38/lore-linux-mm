Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 251B96B00E8
	for <linux-mm@kvack.org>; Sun, 22 Apr 2012 05:35:37 -0400 (EDT)
Message-ID: <4F93D0D9.3050901@redhat.com>
Date: Sun, 22 Apr 2012 12:35:21 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
References: <1334356721-9009-1-git-send-email-yinghan@google.com> <20120420151143.433c514e.akpm@linux-foundation.org>
In-Reply-To: <20120420151143.433c514e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>

On 04/21/2012 01:11 AM, Andrew Morton wrote:
> On Fri, 13 Apr 2012 15:38:41 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > The mmu_shrink() is heavy by itself by iterating all kvms and holding
> > the kvm_lock. spotted the code w/ Rik during LSF, and it turns out we
> > don't need to call the shrinker if nothing to shrink.
> > 
>
> We should probably tell the kvm maintainers about this ;)
>


Andrew, I see you added this to -mm.  First, it should go through the
kvm tree.  Second, unless we misunderstand something, the patch does
nothing, so I don't think it should be added at all.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
