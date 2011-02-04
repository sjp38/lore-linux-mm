Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 68D8C8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 23:16:07 -0500 (EST)
Received: by pvc30 with SMTP id 30so401410pvc.14
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 20:16:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1296743166-9412-2-git-send-email-hannes@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
	<1296743166-9412-2-git-send-email-hannes@cmpxchg.org>
Date: Fri, 4 Feb 2011 09:46:05 +0530
Message-ID: <AANLkTim584=bgyoRux18C=yNniAdof28=xLxS+vnaApT@mail.gmail.com>
Subject: Re: [patch 1/5] memcg: no uncharged pages reach page_cgroup_zoneinfo
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 3, 2011 at 7:56 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> All callsites check PCG_USED before passing pc->mem_cgroup, so the
> latter is never NULL.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
