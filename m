Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA206B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 01:18:16 -0500 (EST)
Date: Thu, 4 Mar 2010 15:14:28 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: update mainteiner list
Message-Id: <20100304151428.d2c0f019.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100304145030.22a35a7e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100304145030.22a35a7e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, balbir@linux.vnet.ibm.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Mar 2010 14:50:30 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Updates for maintainer list of memcg.
> I'd like to add Nishimura-san to maintainer of memcg, he works really well.
> And I'm sorry that I've not seen Pavel on memcg discussion for a year.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Nishimura-san have been working for memcg very good.
> His review and tests give us much improvements and account migraiton
> which he is now challenging is really important.
> 
> He is a stakeholder.
> 
Ack the part of adding my name.

Thanks,
Daisuke Nishimura.

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  MAINTAINERS |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: mmotm-2.6.33-Mar2/MAINTAINERS
> ===================================================================
> --- mmotm-2.6.33-Mar2.orig/MAINTAINERS
> +++ mmotm-2.6.33-Mar2/MAINTAINERS
> @@ -3675,7 +3675,7 @@ F:	mm/
>  
>  MEMORY RESOURCE CONTROLLER
>  M:	Balbir Singh <balbir@linux.vnet.ibm.com>
> -M:	Pavel Emelyanov <xemul@openvz.org>
> +M:	Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>  M:	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>  L:	linux-mm@kvack.org
>  S:	Maintained
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
