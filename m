Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D4F9E6B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 21:53:59 -0400 (EDT)
Message-ID: <49B86B3A.2050506@cn.fujitsu.com>
Date: Thu, 12 Mar 2009 09:54:02 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 6/5] softlimit document
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com> <20090312100112.6f010cae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312100112.6f010cae.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> +    - memory.softlimit_priority.
> +	- priority of this cgroup at softlimit reclaim.
> +	  Allowed priority level is 3-0 and 3 is the lowest.
> +	  If 0, this cgroup will not be target of softlimit.
> +

Seems this document is the older one...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
