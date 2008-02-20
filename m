Date: Wed, 20 Feb 2008 19:07:40 +0900 (JST)
Message-Id: <20080220.190740.84944898.taka@valinux.co.jp>
Subject: Re: Clean up force_empty
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080220173222.3d376a0b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080220.152753.98212356.taka@valinux.co.jp>
	<20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com>
	<20080220173222.3d376a0b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: hugh@veritas.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

> How about this ?

Looks good but I found a typo in the comment.

> +		lock_page_cgroup(page);
> +		/* Because we released lock, we have to chack the page still
						        ^^^^^
							check
> +		   points this pc. */

Thank you,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
