Date: Fri, 11 Jan 2008 13:36:03 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 10/19] No Reclaim LRU Infrastructure
In-Reply-To: <20080108210008.383114457@redhat.com>
References: <20080108205939.323955454@redhat.com> <20080108210008.383114457@redhat.com>
Message-Id: <20080111133048.FD5C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi Rik

> +config NORECLAIM
> +	bool "Track non-reclaimable pages (EXPERIMENTAL; 64BIT only)"
> +	depends on EXPERIMENTAL && 64BIT
> +	help
> +	  Supports tracking of non-reclaimable pages off the [in]active lists
> +	  to avoid excessive reclaim overhead on large memory systems.  Pages
> +	  may be non-reclaimable because:  they are locked into memory, they
> +	  are anonymous pages for which no swap space exists, or they are anon
> +	  pages that are expensive to unmap [long anon_vma "related vma" list.]

Why do you select to default is NO ?
I think this is really improvement and no one of 64bit user
hope turn off without NORECLAIM developer :)


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
