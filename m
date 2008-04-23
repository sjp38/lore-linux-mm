Date: Wed, 23 Apr 2008 22:06:37 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 01/18] hugetlb: fix lockdep spew
In-Reply-To: <20080423015429.726163000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net> <20080423015429.726163000@nick.local0.net>
Message-Id: <20080423220416.E3B0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Hi

>  
>  		spin_lock(&dst->page_table_lock);
> -		spin_lock(&src->page_table_lock);
> +		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
>  		if (!pte_none(*src_pte)) {
>  			if (cow)
>  				ptep_set_wrprotect(src, addr, src_pte);
> 

Good improvement :)

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
