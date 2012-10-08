Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id C48E76B005A
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 04:49:27 -0400 (EDT)
Date: Mon, 8 Oct 2012 10:49:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -mm] mm-memcg-clean-up mm_match_cgroup()-signature-fix-fix
Message-ID: <20121008084923.GA21316@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

Hi Andrew,
I accidentally removed mm commit email so I cannot reply to it but
please we need this follow up fix. I have already merged it to my mm git
tree because it is not compileable otherwise.
---
