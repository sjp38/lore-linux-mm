Date: Fri, 09 Jan 2004 18:41:58 +0900 (JST)
Message-Id: <20040109.184158.128598672.taka@valinux.co.jp>
Subject: Re: [PATCH] dynamic allocation of huge continuous pages 
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20040109041546.5F2B82C071@lists.samba.org>
References: <20040108.203734.122074391.taka@valinux.co.jp>
	<20040109041546.5F2B82C071@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rusty@rustcorp.com.au
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

Thank you for your advice.

> > +		list_for_each(p, &area->free_list) {
> > +			page = list_entry(p, struct page, list);
> 
> Just FYI, "list_for_each_entry(page, &area->free_list, list)" is
> shorter and neater.
> 
> Cheers,
> Rusty.

Thank you,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
