Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C137D828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 15:24:50 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id b14so453410198wmb.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 12:24:50 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lx4si12024079wjb.35.2016.01.14.12.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 12:24:49 -0800 (PST)
Date: Thu, 14 Jan 2016 15:24:08 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/2] mm: memcontrol: cgroup2 memory statistics
Message-ID: <20160114202408.GA20218@cmpxchg.org>
References: <1452722469-24704-1-git-send-email-hannes@cmpxchg.org>
 <20160113144916.03f03766e201b6b04a8a47cc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160113144916.03f03766e201b6b04a8a47cc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Jan 13, 2016 at 02:49:16PM -0800, Andrew Morton wrote:
> It would be nice to see example output, and a description of why this
> output was chosen: what was included, what was omitted, why it was
> presented this way, what units were chosen for displaying the stats and
> why.  Will the things which are being displayed still be relevant (or
> even available) 10 years from now.  etcetera.
> 
> And the interface should be documented at some point.  Doing it now
> will help with the review of the proposed interface.
> 
> Because this stuff is forever and we have to get it right.

Here is a follow-up to 1/2 that hopefully addresses all that, as well
as the 32-bit overflow problem. What do you think? I'm probably a bit
too optimistic with being able to maintain a meaningful sort order of
the file when adding new entries. It depends on whether people start
relying on items staying at fixed offsets and what we tell them in
response when that breaks. I hope that we can at least get the main
memory consumers in before this is released, just in case.
