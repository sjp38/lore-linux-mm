Date: Mon, 10 Nov 2008 13:30:54 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 5/6] memcg: mem+swap controller
Message-Id: <20081110133054.b090816c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081105172316.354c00fb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
	<20081105172316.354c00fb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

> @@ -1062,13 +1208,55 @@ int mem_cgroup_resize_limit(struct mem_c
>  			break;
>  		}
>  		progress = try_to_free_mem_cgroup_pages(memcg,
> -				GFP_HIGHUSER_MOVABLE);
> +				GFP_HIGHUSER_MOVABLE, false);
>  		if (!progress)
>  			retry_count--;
>  	}
>  	return ret;
>  }
>  
mem_cgroup_resize_limit() should verify that mem.limit <= memsw.limit
as mem_cgroup_resize_memsw_limit() does.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
