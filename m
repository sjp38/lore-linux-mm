Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 40E438D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 05:11:34 -0500 (EST)
Date: Mon, 28 Feb 2011 11:11:29 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 2/2] page_cgroup array is never stored on reserved pages
Message-ID: <20110228101129.GE4648@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>

The follow up patch to clean up up PageReserved left overs.
--- 
