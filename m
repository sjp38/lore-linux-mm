From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <8810892.1217233361632.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 28 Jul 2008 17:22:41 +0900 (JST)
Subject: Re: Re: [mmtom] please drop memcg-handle-swap-cache set (memcg handle swap cache rework).
In-Reply-To: <4883CDEB.2030403@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <4883CDEB.2030403@linux.vnet.ibm.com>
 <20080717124556.3e4b6e20.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, xemul@openvz.org, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

----- Original Message -----

>My understanding of this patchset now is that
>
>If the page was ever mapped or cached, we don't tweak add_to_swap_cache(),
>instead, we keep the page around in the memcg, till it is removed from swap
>cache. Is my understanding of your intent correct?
>
Yes, correct.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
