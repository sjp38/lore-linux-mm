Message-Id: <5.0.2.1.2.20010309003257.00abeac0@pop.cus.cam.ac.uk>
Date: Fri, 09 Mar 2001 00:39:40 +0000
From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: [PATCH] documentation mm.h + swap.h
In-Reply-To: <Pine.LNX.4.33.0103081807260.1314-100000@duckman.distro.con
 ectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

At 21:10 08/03/2001, Rik van Riel wrote:
>+ * There is also a hash table mapping (inode,offset) to the page
>+ * in memory if present. The lists for this hash table use the fields
>+ * page->next_hash and page->pprev_hash.

Shouldn't (inode,offset) be (inode,index), or possibly (mapping,index)?

>+ * For choosing which pages to swap out, inode pages carry a
>+ * PG_referenced bit, which is set any time the system accesses
>+ * that page through the (inode,offset) hash table. This referenced

And here, too?

I know these are small details, but just for completeness sake...

Best regards,

         Anton


-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Linux NTFS Maintainer / WWW: http://sourceforge.net/projects/linux-ntfs/
ICQ: 8561279 / WWW: http://www-stu.christs.cam.ac.uk/~aia21/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
