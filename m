Received: from localhost (localhost.localdomain [127.0.0.1])
	by einstein.tteng.com.br (Postfix) with ESMTP id 8E5FEDE800D
	for <linux-mm@kvack.org>; Fri, 13 Aug 2004 13:06:53 -0300 (BRT)
Received: from [192.168.0.141] (luciano.tteng.com.br [192.168.0.141])
	by einstein.tteng.com.br (Postfix) with ESMTP id 7A49012003D
	for <linux-mm@kvack.org>; Fri, 13 Aug 2004 13:06:52 -0300 (BRT)
Message-ID: <411CE8BA.6060401@tteng.com.br>
Date: Fri, 13 Aug 2004 13:13:46 -0300
From: "Luciano A. Stertz" <luciano@tteng.com.br>
MIME-Version: 1.0
Subject: Pointers to contiguous pages
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

alloc_pages with the desired order of pages. I'll fill these pages with 
data and need to add them to the page cache. So I need individual 
pointers to each page contained in the buffer. How do I get them?
     Is the following code correct?

     unsigned long pfn;
     struct page *page = alloc_pages(mask, order);
     if (!page)
         return;

     /* Fill the pages... */

     pfn = page_to_pfn(page)
     for (i=0; i<(1<<order); i++, pfn++)
     {
         struct page *p = pfn_to_page(pfn);
         ...
     }

     Is this correct? Is there a better way to do this?

     Thanks in advance,
         Luciano

	P.S.: I tryied kernelnewbies first, but I guess the question is too 
specific, nobody answered yet...


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
