Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D62566B027B
	for <linux-mm@kvack.org>; Tue,  8 May 2018 08:50:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l47-v6so21406852qtk.21
        for <linux-mm@kvack.org>; Tue, 08 May 2018 05:50:21 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w5-v6si10049763qte.251.2018.05.08.05.50.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 05:50:20 -0700 (PDT)
Date: Tue, 8 May 2018 13:49:16 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: fix oom_kill event handling
Message-ID: <20180508124743.GA26112@castle.DHCP.thefacebook.com>
References: <20180508120402.3159-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180508120402.3159-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, May 08, 2018 at 01:04:02PM +0100, Roman Gushchin wrote:
> Commit e27be240df53 ("mm: memcg: make sure memory.events is
> uptodate when waking pollers") converted most of memcg event
> counters to per-memcg atomics, which made them less confusing
> for a user. The "oom_kill" counter remained untouched, so now
> it behaves differently than other counters (including "oom").
> This adds nothing but confusion.

Please, ignore this one. Version 2 is properly rebased on top
of the mm tree.

Thanks!
