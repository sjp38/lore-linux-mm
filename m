Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 2A97A6B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:04:12 -0400 (EDT)
Date: Tue, 16 Oct 2012 00:04:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v2] memcg: oom: fix totalpages calculation for
 memory.swappiness==0
Message-ID: <20121015220354.GA11682@dhcp22.suse.cz>
References: <20121011085038.GA29295@dhcp22.suse.cz>
 <1349945859-1350-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1349945859-1350-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

As Kosaki correctly pointed out, the glogal reclaim doesn't have this
issue because we _do_ swap on swappinnes==0 so the swap space has
to be considered. So the v2 is just acks + changelog fix.

Changes since v1
- drop a note about global swappiness affected as well from the
  changelog
- stable needs 3.2+ rather than 3.5+ because the fe35004f has been
  backported to stable
---
