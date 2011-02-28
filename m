Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED278D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 05:09:28 -0500 (EST)
Date: Mon, 28 Feb 2011 11:09:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/2] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM
Message-ID: <20110228100920.GD4648@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Andrew,
could you consider the patch bellow, please?
The patch was discussed at https://lkml.org/lkml/2011/2/23/232
---
