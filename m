Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id D43A36B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:07:36 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id c1so7429663lbw.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:07:36 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id z10si4715633wjj.209.2016.06.16.04.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 04:07:35 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id r5so10620931wmr.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:07:35 -0700 (PDT)
Date: Thu, 16 Jun 2016 13:07:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
Message-ID: <20160616110733.GB12437@dhcp22.suse.cz>
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <1465804259-29345-4-git-send-email-minchan@kernel.org>
 <20160613150653.GA30642@cmpxchg.org>
 <20160615004027.GA17127@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160615004027.GA17127@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Sangwoo Park <sangwoo2.park@lge.com>

On Wed 15-06-16 09:40:27, Minchan Kim wrote:
[...]
> A question is it seems cgroup2 doesn't have per-cgroup swappiness.
> Why?

There was no strong use case for it AFAICT.
 
> I think we need it in one-cgroup-per-app model.

I wouldn't be opposed if it is really needed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
