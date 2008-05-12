Message-ID: <48280DFD.20409@openvz.org>
Date: Mon, 12 May 2008 13:29:33 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: avoid unnecessary initialization
References: <20080509145941.f68e8f66.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080509145941.f68e8f66.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> An easy cut out from memcg: performance improvement patch set.
> Tested on: x86-64/linux-2.6.26-rc1-git6
> 
> Thanks,
> -Kame
> ==
> * remove over-killing initialization (in fast path)
> * makeing the condition for PAGE_CGROUP_FLAG_ACTIVE be more obvious.
> 
> Signed-off-by: KAMEAZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
