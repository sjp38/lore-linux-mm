Date: Mon, 18 Jun 2007 09:56:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/7] KAMEZAWA Hiroyuki hot-remove patches
In-Reply-To: <20070618092841.7790.48917.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0706180954320.4751@schroedinger.engr.sgi.com>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
 <20070618092841.7790.48917.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007, Mel Gorman wrote:

> @@ -632,18 +632,27 @@ static int unmap_and_move(new_page_t get
>  			goto unlock;
>  		wait_on_page_writeback(page);
>  	}
> -
> +	/* anon_vma should not be freed while migration. */
> +	if (PageAnon(page)) {
> +		rcu_read_lock();
> +		rcu_locked = 1;
> +	}

We agreed on doing rcu_read_lock removing the status variable 
and checking for PageAnon(). Doing so deuglifies the 
function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
