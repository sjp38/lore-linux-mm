Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 78C2D6B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 20:09:20 -0500 (EST)
Date: Thu, 7 Feb 2013 10:09:14 +0900
From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 6/7] net: change type of netns_ipvs->sysctl_sync_qlen_max
Message-ID: <20130207010914.GA9070@verge.net.au>
References: <alpine.LFD.2.00.1302061115590.1664@ja.ssi.bg>
 <5112240C.1010105@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5112240C.1010105@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Julian Anastasov <ja@ssi.bg>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, mgorman@suse.de

On Wed, Feb 06, 2013 at 05:36:12PM +0800, Zhang Yanfei wrote:
> ao? 2013a1'02ae??06ae?JPY 17:29, Julian Anastasov a??e??:
> > 
> > 	Hello,
> > 
> > 	Sorry that I'm writing a private email but I
> > deleted your original message by mistake. Your change
> > of the sysctl_sync_qlen_max from int to long is may be
> > not enough.
> > 
> > 	net/netfilter/ipvs/ip_vs_ctl.c contains
> > proc var "sync_qlen_max" that should be changed to
> > sizeof(unsigned long) and updated with proc_doulongvec_minmax.
> > 
> 
> Thanks for pointing this. I will update this in patch v2.

Hi Zhang,

Thanks for helping to keep IPVS up to date.

It seems to me that include/net/ip_vs.h:sysctl_sync_qlen_max()
and its call site, net/netfilter/ipvs/ip_vs_sync.c:sb_queue_tail()
may also need to be updated.

Could you look at including that in v2 too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
