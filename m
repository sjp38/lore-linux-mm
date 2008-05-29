Subject: Re: [RFC 1/2] memcg: hierarchy support core (yet another one)
In-Reply-To: Your message of "Wed, 28 May 2008 16:56:20 +0900"
	<20080528165620.68f4d911.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080528165620.68f4d911.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080529051104.2C4995A0E@siro.lan>
Date: Thu, 29 May 2008 14:11:04 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> @@ -39,6 +39,18 @@ struct res_counter {
>  	 */
>  	unsigned long long failcnt;
>  	/*
> +	 * the amount of resource comes from parenet cgroup. Should be
> +	 * returned to the parent at destroying/resizing this res_counter.
> +	 */
> +	unsigned long long borrow;

why do you need this in addition to the limit?
ie. aren't their values always equal except the root cgroup?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
