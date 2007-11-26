Date: Mon, 26 Nov 2007 19:19:49 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch] mm/sparse.c: Improve the error handling for sparse_add_one_section()
In-Reply-To: <20071123055150.GA2488@hacking>
References: <1195507022.27759.146.camel@localhost> <20071123055150.GA2488@hacking>
Message-Id: <20071126191316.99CF.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Cong-san.

>  	ms->section_mem_map |= SECTION_MARKED_PRESENT;
>  
>  	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
>  out:
>  	pgdat_resize_unlock(pgdat, &flags);
> -	if (ret <= 0)
> -		__kfree_section_memmap(memmap, nr_pages);
> +
>  	return ret;
>  }
>  #endif

Hmm. When sparse_init_one_section() returns error, memmap and 
usemap should be free.

Thanks for your fixing.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
