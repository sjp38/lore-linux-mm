Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id D92ED6B13F0
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 07:37:25 -0500 (EST)
Received: by wera13 with SMTP id a13so3325738wer.14
        for <linux-mm@kvack.org>; Sat, 11 Feb 2012 04:37:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1328909806-15236-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Sat, 11 Feb 2012 20:37:23 +0800
Message-ID: <CAJd=RBCRG1oXV6jjxxatXEpk5MipL-PyapSoYFMEhK-==YOVaw@mail.gmail.com>
Subject: Re: [RFC PATCH 0/6] hugetlbfs: Add cgroup resource controller for hugetlbfs
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

On Sat, Feb 11, 2012 at 5:36 AM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> Hi,
>
> This patchset implements a cgroup resource controller for HugeTLB pages.
> It is similar to the existing hugetlb quota support in that the limit is
> enforced at mmap(2) time and not at fault time. HugeTLB quota limit the
> number of huge pages that can be allocated per superblock.
>

Hello Aneesh

Thanks for your work:)

Mind to post the whole patchset on LKML with Andrea, Michal,
Johannes and Andrew also Cced, for more eyes and thoughts?

Good weekend
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
