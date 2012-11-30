Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id EE2DD6B006E
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 04:08:40 -0500 (EST)
Message-ID: <50B87793.7000104@parallels.com>
Date: Fri, 30 Nov 2012 13:08:35 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch v2 5/6] memcg: further simplify mem_cgroup_iter
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz> <1353955671-14385-6-git-send-email-mhocko@suse.cz>
In-Reply-To: <1353955671-14385-6-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Li Zefan <lizefan@huawei.com>

On 11/26/2012 10:47 PM, Michal Hocko wrote:
> The code would be much more easier to follow if we move the iteration
> outside of the function (to __mem_cgrou_iter_next) so the distinction
> is more clear.
totally nit: Why is it call __mem_cgrou ?

What happened to your p ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
