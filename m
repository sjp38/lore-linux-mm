Date: Sat, 6 Dec 2008 12:42:23 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH -mmotm 0/4] patches for memory cgroup (20081205)
Message-Id: <20081206124223.665d7d3c.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
References: <20081205212208.31d904e0.nishimura@mxp.nes.nec.co.jp>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, d-nishimura@mtf.biglobe.ne.jp
List-ID: <linux-mm.kvack.org>

On Fri, 5 Dec 2008 21:22:08 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> These are patches that I have now.
> 
> Patches:
>   [1/4] memcg: don't trigger oom at page migration
>   [2/4] memcg: remove mem_cgroup_try_charge
>   [3/4] memcg: avoid deadlock caused by race between oom and cpuset_attach
>   [4/4] memcg: change try_to_free_pages to hierarchical_reclaim
> 
> There is no special meaning in patch order except for 1 and 2.
> 
> Any comments would be welcome.
> 
Thank you for all your reviews and acks.

I'll send them to Andrew after I back to my office on Monday.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
