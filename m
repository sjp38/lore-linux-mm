Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA26577
	for <linux-mm@kvack.org>; Tue, 16 Mar 1999 07:29:40 -0500
Date: Tue, 16 Mar 1999 12:22:27 GMT
Message-Id: <199903161222.MAA01394@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: A couple of questions
In-Reply-To: <19990316074606.A10483@tc-1-192.ariake.gol.ne.jp>
References: <36DBE391.EF9C1C06@earthling.net>
	<199903151858.SAA02057@dax.scot.redhat.com>
	<19990316074606.A10483@tc-1-192.ariake.gol.ne.jp>
Sender: owner-linux-mm@kvack.org
To: neil@tc-1-192.ariake.gol.ne.jp
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 16 Mar 1999 07:46:06 +0900, neil@tc-1-192.ariake.gol.ne.jp
said:

> Thanks for your reply.  I think you've missed my point on this one.
> The variable "pte" is set before calling __get_free_page(), and being
> local cannot be modified by other processes.  

Umm, OK, you've convinced me. :) I think we have enough locks held
throughout this to prevent the present or writable bits in *page_table
from changing between the test in handle_pte_fault() and do_wp_page()
itself, even on SMP.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
