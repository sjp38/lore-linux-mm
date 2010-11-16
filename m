Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD358D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 05:17:32 -0500 (EST)
Date: Tue, 16 Nov 2010 11:17:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] Make swap accounting default behavior configurable
Message-ID: <20101116101726.GA21296@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi Andrew,
could you consider the following patch for the Linus tree, please?
The discussion took place in this email thread 
http://lkml.org/lkml/2010/11/10/114.
The patch is based on top of 151f52f09c572 commit in the Linus tree.

Please let me know if there I should route this patch through somebody
else.

Thanks!

---
