Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77DBF6B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 08:00:37 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x26-v6so4141352qtb.2
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 05:00:37 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b18-v6si2749475qkc.98.2018.08.03.05.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 05:00:36 -0700 (PDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <190b28da-aca8-1c72-0933-94de08a48019@virtuozzo.com>
References: <190b28da-aca8-1c72-0933-94de08a48019@virtuozzo.com> <47c34fad-5d11-53b0-4386-61be890163c5@virtuozzo.com> <153320759911.18959.8842396230157677671.stgit@localhost.localdomain> <20180802134723.ecdd540c7c9338f98ee1a2c6@linux-foundation.org> <8347.1533292272@warthog.procyon.org.uk> <5250d5c0-0d26-260e-dc39-227b8e355a1b@virtuozzo.com>
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to do_shrink_slab()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <19045.1533297627.1@warthog.procyon.org.uk>
Date: Fri, 03 Aug 2018 13:00:27 +0100
Message-ID: <19046.1533297627@warthog.procyon.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org

Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> > Before I also try to check why it works; just reporting you that the patch
> > works the problem in my environment. Thanks, David.
> 
> patch *fixes* the problem

Thanks.  I've folded the patch in.

David
