Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 491A96B0036
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 04:25:50 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so3853528wiv.17
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 01:25:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sb15si13226339wjb.114.2014.07.15.01.25.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 01:25:47 -0700 (PDT)
Date: Tue, 15 Jul 2014 10:25:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715082545.GA9366@dhcp22.suse.cz>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

As there were follow up fixed on top of this one I have squashed them
into the following one (changelogs preserved) for review. I hope I
haven't missed any patch. I will respond to this email with the review
comments. It is quite large so it will take some time...
---
