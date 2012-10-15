Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 89C2B6B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:07:28 -0400 (EDT)
Date: Tue, 16 Oct 2012 00:07:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] doc: describe memcg swappiness more precisely
 memory.swappiness==0
Message-ID: <20121015220725.GB11682@dhcp22.suse.cz>
References: <20121011085038.GA29295@dhcp22.suse.cz>
 <1349945859-1350-1-git-send-email-mhocko@suse.cz>
 <20121015220354.GA11682@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121015220354.GA11682@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

And a follow up for memcg.swappiness documentation which is more
specific about spwappiness==0 meaning.
---
