Message-ID: <41065AD0.5070303@tteng.com.br>
Date: Tue, 27 Jul 2004 10:38:24 -0300
From: "Luciano A. Stertz" <luciano@tteng.com.br>
MIME-Version: 1.0
Subject: Re: Read-ahead code
References: <410658B6.3020701@tteng.com.br>
In-Reply-To: <410658B6.3020701@tteng.com.br>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
Cc: "Luciano A. Stertz" <luciano@tteng.com.br>
List-ID: <linux-mm.kvack.org>


	Oops, it's already fixed in 2.6.8-rc2, forget it.

	Luciano

Luciano A. Stertz wrote:
>     I guess I found a bug in the readahead code, kernel 2.6.7.
>     In filemap_nopage, if the memory area is not marked as sequential 
> (VM_SEQ_READ isn't set) and the page is not in the page cache, the 
> following code is executed:
> 
> 1                ra_pages = max_sane_readahead(file->f_ra.ra_pages);
> 2                if (ra_pages) {
> 3                        long start;
> 4
> 5                        start = pgoff - ra_pages / 2;
> 6                        if (pgoff < 0)
> 7                                pgoff = 0;
> 8                        do_page_cache_readahead(mapping, file, pgoff, 
> ra_pages);
> 9                }
> 
>     Seems that the author wanted to read ra_pages around pgoff. 
> Shouldn't it be using 'start' instead of 'pgoff' in lines 6 to 8?!? 
> Start is calculated and never used. Instead of reading pages from start 
> to pgoff + ra_pages/2, it's reading ra_pages from pgoff.
> 
>     Luciano
> 


-- 
Luciano A. Stertz
luciano@tteng.com.br
T&T Engenheiros Associados Ltda
http://www.tteng.com.br
Fone/Fax (51) 3224 8425
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
