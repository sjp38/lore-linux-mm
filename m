Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 74D906B0002
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 11:12:48 -0400 (EDT)
Date: Mon, 25 Mar 2013 16:12:46 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 10/10] prepare to remove
 /proc/sys/vm/hugepages_treat_as_movable
Message-ID: <20130325151246.GB2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-11-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363983835-20184-11-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri 22-03-13 16:23:55, Naoya Horiguchi wrote:
[...]
> @@ -2086,11 +2085,7 @@ int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
>  			void __user *buffer,
>  			size_t *length, loff_t *ppos)
>  {
> -	proc_dointvec(table, write, buffer, length, ppos);
> -	if (hugepages_treat_as_movable)
> -		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
> -	else
> -		htlb_alloc_mask = GFP_HIGHUSER;
> +	/* hugepages_treat_as_movable is obsolete and to be removed. */

WARN_ON_ONCE("This knob is obsolete and has no effect. It is scheduled for removal")
>  	return 0;
>  }
>  
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
