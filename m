From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] dynamic allocation of huge continuous pages 
In-reply-to: Your message of "Thu, 08 Jan 2004 20:37:34 +0900."
             <20040108.203734.122074391.taka@valinux.co.jp>
Date: Fri, 09 Jan 2004 14:56:18 +1100
Message-Id: <20040109041546.5F2B82C071@lists.samba.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In message <20040108.203734.122074391.taka@valinux.co.jp> you write:
> +		list_for_each(p, &area->free_list) {
> +			page = list_entry(p, struct page, list);

Just FYI, "list_for_each_entry(page, &area->free_list, list)" is
shorter and neater.

Cheers,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
