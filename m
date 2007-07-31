Subject: Re: [-mm PATCH 4/9] Memory controller memory accounting (v4)
In-Reply-To: Your message of "Sat, 28 Jul 2007 01:40:18 +0530"
	<20070727201018.31565.42132.sendpatchset@balbir-laptop>
References: <20070727201018.31565.42132.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20070731033832.9E8B41BF6B4@siro.lan>
Date: Tue, 31 Jul 2007 12:38:32 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> +	lock_meta_page(page);
> +	/*
> +	 * Check if somebody else beat us to allocating the meta_page
> +	 */
> +	race_mp = page_get_meta_page(page);
> +	if (race_mp) {
> +		kfree(mp);
> +		mp = race_mp;
> +		atomic_inc(&mp->ref_cnt);
> +		res_counter_uncharge(&mem->res, 1);
> +		goto done;
> +	}

i think you need css_put here.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
