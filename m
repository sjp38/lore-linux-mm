Date: Tue, 16 Oct 2007 21:17:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memory cgroup enhancements [3/5] record pc is on active
 list
In-Reply-To: <20071016192613.350d0bb5.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.0.9999.0710162117090.13648@chino.kir.corp.google.com>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com> <20071016192613.350d0bb5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Oct 2007, KAMEZAWA Hiroyuki wrote:

> Remember page_cgroup is on active_list or not in page_cgroup->flags.
> 
> Against 2.6.23-mm1.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
> 
>  mm/memcontrol.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> Index: devel-2.6.23-mm1/mm/memcontrol.c
> ===================================================================
> --- devel-2.6.23-mm1.orig/mm/memcontrol.c
> +++ devel-2.6.23-mm1/mm/memcontrol.c
> @@ -85,6 +85,7 @@ struct page_cgroup {
>  					/* mapped and cached states     */
>  	int	 flags;
>  #define PCGF_PAGECACHE		(0x1)	/* charged as page-cache */
> +#define PCGF_ACTIVE		(0x2)	/* this is on cgroup's active list */

Please move these flag #defines out of the struct definition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
