Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 49F4F6B01F9
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 19:07:46 -0500 (EST)
Date: Mon, 12 Dec 2011 19:07:34 -0500 (EST)
Message-Id: <20111212.190734.1967808916779299221.davem@davemloft.net>
Subject: Re: [PATCH v9 0/9] Request for inclusion: per-cgroup tcp memory
 pressure controls
From: David Miller <davem@davemloft.net>
In-Reply-To: <1323676029-5890-1-git-send-email-glommer@parallels.com>
References: <1323676029-5890-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org

From: Glauber Costa <glommer@parallels.com>
Date: Mon, 12 Dec 2011 11:47:00 +0400

> This series fixes all the few comments raised in the last round,
> and seem to have acquired consensus from the memcg side.
> 
> Dave, do you think it is acceptable now from the networking PoV?
> In case positive, would you prefer merging this trough your tree,
> or acking this so a cgroup maintainer can do it?

All applied to net-next, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
