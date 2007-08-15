Subject: Re: [-mm PATCH 4/9] Memory controller memory accounting (v4)
In-Reply-To: Your message of "Tue, 31 Jul 2007 18:14:26 +0530"
	<46AF2EAA.2080703@linux.vnet.ibm.com>
References: <46AF2EAA.2080703@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20070815084454.09B061BF982@siro.lan>
Date: Wed, 15 Aug 2007 17:44:53 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: svaidy@linux.vnet.ibm.com
Cc: a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, menage@google.com, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> YAMAMOTO Takashi wrote:
> >> +	lock_meta_page(page);
> >> +	/*
> >> +	 * Check if somebody else beat us to allocating the meta_page
> >> +	 */
> >> +	race_mp = page_get_meta_page(page);
> >> +	if (race_mp) {
> >> +		kfree(mp);
> >> +		mp = race_mp;
> >> +		atomic_inc(&mp->ref_cnt);
> >> +		res_counter_uncharge(&mem->res, 1);
> >> +		goto done;
> >> +	}
> > 
> > i think you need css_put here.
> 
> Thats correct. We do need css_put in this path.
> 
> Thanks,
> Vaidy

v5 still seems to have the problem.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
