Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8766B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 09:57:37 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id k184so21321720wme.4
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 06:57:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 74si50591656wmh.144.2016.12.28.06.57.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 06:57:36 -0800 (PST)
Date: Wed, 28 Dec 2016 15:57:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [LSF/MM TOPIC] plans for future swap changes
Message-ID: <20161228145732.GE11470@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>

This is something I would be interested to discuss even though I am not
working on it directly. Sorry if I hijacked the topic from those who
planned to post them.

It seems that the time to reconsider our approach to the swap storage is
come already and there are multiple areas to discuss. I would be
interested at least in the following
1) anon/file balancing. Johannes has posted some work already and I am
   really interested in the future plans for it.
2) swap trashing detection is something that we are lacking for a long
   time and it would be great if we could do something to help
   situations when the machine is effectively out of memory but still
   hopelessly trying to swap in and out few pages while the machine is
   basically unusable. I hope that 1) will give us some bases but I am
   not sure how much we will need on top.
3) optimizations for the swap out paths - Tim Chen and other guys from
   Intel are already working on this. I didn't get time to review this
   closely - mostly because I am not closely familiar with the swapout
   code and it takes quite some time to get into all subtle details.
   I mainly interested in what are the plans in this area and how they
   should be coordinated with other swap related changes
4) Do we want the native THP swap in/out support?

Other plans?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
