From: Leandro Motta Barros <lmb@exatas.unisinos.br>
Subject: __vmalloc and alloc_page
Date: Wed, 17 Sep 2003 13:26:11 -0300
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200309171326.11848.lmb@exatas.unisinos.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>

Hello again,

Thanks for the feedback on the previous email. Well, there is another thing we 
thought that could be done. '__vmalloc()' allocates its memory by calling 
'alloc_page()' for every necessary page. Wouldn't it be better calling 
'alloc_pages()' to allocate more pages at once whenever possible? We would 
need more bookeepping, and sometimes it could be necessary to actually 
allocate the memory page per page, but we think this approach could be a way 
to use memory blocks of higher order.

Do you think this is feasible or useful?

Also, we would like to know if you have suggestions on topics that we could 
explore and implement.

LMB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
