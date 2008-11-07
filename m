Date: Fri, 7 Nov 2008 22:21:08 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 5/6] memcg: mem+swap controller
Message-Id: <20081107222108.9f7152c2.nishimura@mxp.nes.nec.co.jp>
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

> @@ -1286,30 +1507,33 @@ static int mem_control_stat_show(struct 
>  		cb->fill(cb, "unevictable", unevictable * PAGE_SIZE);
>  
>  	}
> +	/* showing refs from disk-swap */
> +	cb->fill(cb, "swap_on_disk", atomic_read(&mem_cont->swapref)
> +					* PAGE_SIZE);
>  	return 0;
>  }
>  
"if (do_swap_account)" is needed here too.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
