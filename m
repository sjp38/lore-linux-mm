Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 35EEA6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 21:56:22 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so2072832pbc.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 18:56:21 -0700 (PDT)
Date: Sat, 21 Apr 2012 10:56:15 +0900
From: Takuya Yoshikawa <takuya.yoshikawa@gmail.com>
Subject: Re: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
Message-Id: <20120421105615.6b0b03640f7553060628d840@gmail.com>
In-Reply-To: <CALWz4iwVhg23X06T6HP49PKa8z2_-KRx6f64vYrvsT+KoaKp8A@mail.gmail.com>
References: <1334356721-9009-1-git-send-email-yinghan@google.com>
	<20120420151143.433c514e.akpm@linux-foundation.org>
	<4F91E8CC.5080409@redhat.com>
	<CALWz4iwVhg23X06T6HP49PKa8z2_-KRx6f64vYrvsT+KoaKp8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Mike Waychison <mikew@google.com>

On Fri, 20 Apr 2012 16:07:41 -0700
Ying Han <yinghan@google.com> wrote:

> My understanding of the real pain is the poor implementation of the
> mmu_shrinker. It iterates all the registered mmu_shrink callbacks for
> each kvm and only does little work at a time while holding two big
> locks. I learned from mikew@ (also ++cc-ed) that is causing latency
> spikes and unfairness among kvm instance in some of the experiment
> we've seen.

Last year, I discussed the mmu_shrink issues on kvm ML:

	[PATCH 0/4] KVM: Make mmu_shrink() scan nr_to_scan shadow pages
	http://www.spinics.net/lists/kvm/msg65231.html

Sadly, we could not find any good way at that time.

Thanks,
	Takuya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
