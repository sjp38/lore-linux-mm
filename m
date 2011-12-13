Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 094F26B0280
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 13:46:05 -0500 (EST)
Date: Tue, 13 Dec 2011 13:45:44 -0500 (EST)
Message-Id: <20111213.134544.897666694310425225.davem@davemloft.net>
Subject: Re: [PATCH v9 0/9] Request for inclusion: per-cgroup tcp memory
 pressure controls
From: David Miller <davem@davemloft.net>
In-Reply-To: <1323784748.2950.4.camel@edumazet-laptop>
References: <20111212.190734.1967808916779299221.davem@davemloft.net>
	<4EE757D7.6060006@uclouvain.be>
	<1323784748.2950.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: christoph.paasch@uclouvain.be, glommer@parallels.com, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, cgroups@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Dec 2011 14:59:08 +0100

> [PATCH net-next] net: fix build error if CONFIG_CGROUPS=n
> 
> Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
