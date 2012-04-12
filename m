Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 879496B007E
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 09:37:26 -0400 (EDT)
Message-ID: <4F86DA32.9060701@parallels.com>
Date: Thu, 12 Apr 2012 10:35:46 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] memcg: remove drain_all_stock_sync.
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BD18.4010505@jp.fujitsu.com>
In-Reply-To: <4F86BD18.4010505@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/12/2012 08:31 AM, KAMEZAWA Hiroyuki wrote:
> Because a function moving pages to ancestor works asynchronously now,
> drain_all_stock_sync() is unnecessary.
> 
> Signed-off-by: KAMEAZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
