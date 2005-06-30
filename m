Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5UIBk8D519542
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 14:11:46 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5UIBjcC158690
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 12:11:45 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5UIBjr0020180
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 12:11:45 -0600
Subject: Re: [ckrm-tech] [PATCH 4/6] CKRM: Add guarantee support for mem
	controller
From: Chandra Seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
In-Reply-To: <1120110730.479552.4689.nullmailer@yamt.dyndns.org>
References: <1119651942.5105.21.camel@linuxchandra>
	 <1120110730.479552.4689.nullmailer@yamt.dyndns.org>
Content-Type: text/plain
Date: Thu, 30 Jun 2005 11:11:44 -0700
Message-Id: <1120155104.14910.36.camel@linuxchandra>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-06-30 at 14:52 +0900, YAMAMOTO Takashi wrote:
> > +static inline void
> > +ckrm_clear_page_class(struct page *page)
> > +{
> > +	struct ckrm_zone *czone = page_ckrmzone(page);
> > +	if (czone == NULL)
> > +		return;
> > +	sub_use_count(czone->memcls, 0, page_zonenum(page), 1);
> > +	kref_put(&czone->memcls->nr_users, memclass_release);
> > +	set_page_ckrmzone(page, NULL);
> >  }
> 
> are you sure if it's safe?
> this function is called with zone->lock held,
> and memclass_release calls kfree.

i don't understand why you think it is a problem to call kfree with lock
held( i agree calling kmalloc with wait flag when a lock is being held
is not correct).

> 
> YAMAMOTO Takashi
-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
