Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 659EC6B0007
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 05:03:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 54-v6so1051331wrw.1
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 02:03:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b8-v6si482405ede.252.2018.06.05.02.03.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 02:03:51 -0700 (PDT)
Date: Tue, 5 Jun 2018 11:03:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: don't skip memory guarantee calculations
Message-ID: <20180605090349.GW19202@dhcp22.suse.cz>
References: <20180522132528.23769-1-guro@fb.com>
 <20180522132528.23769-2-guro@fb.com>
 <20180604122953.GN19202@dhcp22.suse.cz>
 <20180604162259.GA3404@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180604162259.GA3404@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon 04-06-18 17:23:06, Roman Gushchin wrote:
[...]
> I'm happy to discuss any concrete issues/concerns, but I really see
> no reasons to drop it from the mm tree now and start the discussion
> from scratch.

I do not think this is ready for the current merge window. Sorry! I
would really prefer to see the whole thing in one series to have a
better picture.

-- 
Michal Hocko
SUSE Labs
