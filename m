Subject: Re: [ckrm-tech] [PATCH 4/6] CKRM: Add guarantee support for mem
 controller
In-Reply-To: Your message of "Fri, 24 Jun 2005 15:25:42 -0700"
	<1119651942.5105.21.camel@linuxchandra>
References: <1119651942.5105.21.camel@linuxchandra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Date: Thu, 30 Jun 2005 14:52:10 +0900
Message-Id: <1120110730.479552.4689.nullmailer@yamt.dyndns.org>
From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +static inline void
> +ckrm_clear_page_class(struct page *page)
> +{
> +	struct ckrm_zone *czone = page_ckrmzone(page);
> +	if (czone == NULL)
> +		return;
> +	sub_use_count(czone->memcls, 0, page_zonenum(page), 1);
> +	kref_put(&czone->memcls->nr_users, memclass_release);
> +	set_page_ckrmzone(page, NULL);
>  }

are you sure if it's safe?
this function is called with zone->lock held,
and memclass_release calls kfree.

YAMAMOTO Takashi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
