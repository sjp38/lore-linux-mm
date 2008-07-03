Date: Thu, 3 Jul 2008 08:03:17 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][-mm] [3/7] add shmem page to active list.
In-Reply-To: <20080703132730.b64dcd19.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0807030750110.22097@blonde.site>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
 <20080702211057.7a7cf3dc.kamezawa.hiroyu@jp.fujitsu.com>
 <20080703091144.93465ba5.kamezawa.hiroyu@jp.fujitsu.com>
 <20080703132730.b64dcd19.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2008, KAMEZAWA Hiroyuki wrote:
> 
> BTW, is there a way to see the RSS usage of shmem from /proc or somewhere ?

No, it's just been a (very weirdly backed!) filesystem until these
-mm developments.  If you add such stats (for more than temporary
debugging), you'll need to use per_cpu counters for it: more global
locking or atomic ops on those paths would be sure to upset SGI.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
