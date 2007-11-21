From: =?ISO-2022-JP?B?GyRCPi46ajtxOS0bKEI=?=
	<kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/6] Use two zonelist that are filtered by GFP mask
Date: Wed, 21 Nov 2007 11:37:21 +0900
Message-ID: <20071121113403.689F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20071121003848.10789.18030.sendpatchset@skynet.skynet.ie> <20071121004008.10789.97361.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755546AbXKUChe@vger.kernel.org>
In-Reply-To: <20071121004008.10789.97361.sendpatchset@skynet.skynet.ie>
Sender: linux-kernel-owner@vger.kernel.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee.Schermerhorn@hp.com, clameter@sgi.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Hi

> +static inline enum zone_type gfp_zonelist(gfp_t flags)
> +{
> +	if (NUMA_BUILD && unlikely(flags & __GFP_THISNODE))
> +		return 1;
> +
> +	return 0;
> +}
> +

static inline int gfp_zonelist(gfp_t flags) ?

if not, why no use ZONE_XXX macro.


----
kosaki
