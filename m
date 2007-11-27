Date: Tue, 27 Nov 2007 20:55:30 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch](Resend) mm/sparse.c: Improve the error handling for sparse_add_one_section()
In-Reply-To: <20071127022609.GA4164@hacking>
References: <20071126191316.99CF.Y-GOTO@jp.fujitsu.com> <20071127022609.GA4164@hacking>
Message-Id: <20071127204623.3D53.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
> @@ -414,7 +418,7 @@ int sparse_add_one_section(struct zone *
>  out:
>  	pgdat_resize_unlock(pgdat, &flags);
>  	if (ret <= 0)
> -		__kfree_section_memmap(memmap, nr_pages);
> +		kfree(usemap);
>  	return ret;
>  }
>  #endif
> 

I guess you think __kfree_section_memmap() is not necessary due to
no implementation. But, it is still available when
CONFIG_SPARSEMEM_VMEMMAP is off. So, it should not be removed.


Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
