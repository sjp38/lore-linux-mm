Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3E682905
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 15:57:55 -0400 (EDT)
Received: by obcuy5 with SMTP id uy5so11356994obc.11
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 12:57:54 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id r2si150851oep.61.2015.03.11.12.57.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 12:57:54 -0700 (PDT)
Received: by oibg201 with SMTP id g201so9966554oib.10
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 12:57:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55006C75.2050604@yandex-team.ru>
References: <1425876632-6681-1-git-send-email-gthelen@google.com> <55006C75.2050604@yandex-team.ru>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 11 Mar 2015 15:57:33 -0400
Message-ID: <CAHH2K0beuz+w71dh5U4FnB522xBW2mf4VhcvJsX2k+wQkLx5GQ@mail.gmail.com>
Subject: Re: [PATCH] memcg: add per cgroup dirty page accounting
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Dave Chinner <david@fromorbit.com>, Sha Zhengju <handai.szj@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Mar 11, 2015 at 12:25 PM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> This patch conflicts with my cleanup which is already in mm tree:
> ("page_writeback: clean up mess around cancel_dirty_page()")
> Nothing nontrivial but I've killed cancel_dirty_page() and replaced
> it which account_page_cleaned() symmetrical to account_page_dirtied().

Fair enough.  I'll rebase.

> I think this accounting can be done without mem_cgroup_begin_page_stat()
> All page cleaning happens under page is lock.
> Some dirtying is called without page-lock when kernel moves
> dirty status from pte to page, but in this case acconting happens
> under mapping->tree_lock.
>
> Memcg already locks pages when moves them between cgroups,
> maybe it could also lock mapping->tree_lock?

Good suggestion.  I'll try it out and report back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
