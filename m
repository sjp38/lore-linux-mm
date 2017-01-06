Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id C81C46B0069
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 11:05:03 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id j94so82549732uad.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 08:05:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a69si3004929wme.110.2017.01.06.08.05.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 08:05:02 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] mm patches review bandwidth
References: <20170105153737.GV21618@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7f6e4880-ae35-6a3f-3b16-ddb9afea9a88@suse.cz>
Date: Fri, 6 Jan 2017 17:05:01 +0100
MIME-Version: 1.0
In-Reply-To: <20170105153737.GV21618@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

On 01/05/2017 04:37 PM, Michal Hocko wrote:
> Hi,
> I have a very bad feeling that we are running out of the patch review
> bandwidth for quite some time. Quite often it is really hard to get
> any feedback at all. This leaves Andrew in an unfortunate position when
> he is pushed to merge changes which are not reviewed.
> 
> A quick check shows that around 40% of patches is not tagged with
> neither Acked-by nor Reviewed-by. While this is not any hard number it
> should give us at least some idea...
> 
> $ git rev-list --no-merges v4.8..v4.9 -- mm/ | wc -l 
> 150
> $ git rev-list --no-merges v4.8..v4.9 -- mm/ | while read sha1; do git show $sha1 | grep "Acked-by\|Reviewed-by" >/dev/null&& echo $sha1; done | wc -l
> 87
> 
> The overall trend since 4.0 shows that this is quite a consistent number
> 
> 123 commits in 4.0..4.1 range 47 % unreviewed
> 170 commits in 4.1..4.2 range 56 % unreviewed
> 187 commits in 4.2..4.3 range 35 % unreviewed
> 176 commits in 4.3..4.4 range 34 % unreviewed
> 220 commits in 4.4..4.5 range 32 % unreviewed
> 199 commits in 4.5..4.6 range 42 % unreviewed
> 217 commits in 4.6..4.7 range 41 % unreviewed
> 247 commits in 4.7..4.8 range 39 % unreviewed
> 150 commits in 4.8..4.9 range 42 % unreviewed

That's better than I pessimistically expected, but still far from great,
yeah.

> I am worried that the number of patches posted to linux-mm grows over
> time while the number of reviewers doesn't scale up with that trend. I
> believe we need to do something about that and aim to increase both the
> number of reviewers as well as the number of patches which are really
> reviewed. I am not really sure how to achieve that, though. Requiring
> Acked-by resp. Reviewed-by on each patch sounds like the right approach
> but I am just worried that even useful changes could get stuck without
> any forward progress that way.

It does work for some other subsystems, so I would be for trying this.
mm is core enough to deserve being careful IMHO.

> Another problem, somehow related, is that there are areas which have
> evolved into a really bad shape because nobody has really payed
> attention to them from the architectural POV when they were merged. To
> name one the memory hotplug doesn't seem very healthy, full of kludges,
> random hacks and fixes for fixes working for a particualr usecase
> without any longterm vision. We have allowed to (ab)use concepts like
> ZONE_MOVABLE which are finding new users because that seems to be the
> simplest way forward. Now we are left with fixing the code which has
> some fundamental issues because it is used out there. Are we going to do
> anything about those? E.g. generate a list of them, discuss how to make
> that code healthy again and do not allow new features until we sort that
> out?

Sounds like we could at least try.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
