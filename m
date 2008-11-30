Received: by fg-out-1718.google.com with SMTP id 13so1570597fge.4
        for <linux-mm@kvack.org>; Sun, 30 Nov 2008 04:25:56 -0800 (PST)
Date: Sun, 30 Nov 2008 15:25:54 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 02/09] memcg: make inactive_anon_is_low()
Message-ID: <20081130122554.GA12552@localhost>
References: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081130195508.814B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081130195508.814B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

[KOSAKI Motohiro - Sun, Nov 30, 2008 at 07:56:37PM +0900]
| make inactive_anon_is_low for memcgroup.
| it improve active_anon vs inactive_anon ratio balancing.
| 
| 
| Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
| ---
...
| +static void mem_cgroup_set_inactive_ratio(struct mem_cgroup *memcg)
| +{
| +	unsigned int gb, ratio;
| +
| +	gb = res_counter_read_u64(&memcg->res, RES_LIMIT) >> 30;
| +	ratio = int_sqrt(10 * gb);
| +	if (!ratio)
| +		ratio = 1;

Hi Kosaki,

maybe better would be

	gb = ...;
	if (gb) {
		ratio = int_sqrt(10 * gb);
	} else
		ratio = 1;

| +
| +	memcg->inactive_ratio = ratio;
| +
| +}
| +
...

		- Cyrill -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
