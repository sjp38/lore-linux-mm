Message-ID: <3B587934.6000103@interactivesi.com>
Date: Fri, 20 Jul 2001 13:32:20 -0500
From: Timur Tabi <ttabi@interactivesi.com>
MIME-Version: 1.0
Subject: Re: Support for Intel 4MB Pages
References: <Pine.A41.3.96.1010720142345.25692A-100000@vcmr-19.rcs.rpi.edu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I thought Linux already used 4MB pages for its 1-to-1 kernel virtual
memory mapping.

Justin Michael LaPre wrote:

 > beneficial to use 4MB pages.  Some people on IRC suggested the community
 > might appreciate such a patch.  Would this be well-accepted? 
Designing it
 > to be general instead of just for our purposes would be more difficult,
 > but we would be willing to put in the time if people actually want it.
 > 	If it were to be implemented, what would be the best strategy?  A
 > new memory zone?  Re-working the mm system to try and not break up chunks
 > of 4MB if possible?  Any comments would be greatly appreciated.  Thanks.
 >
 > -Justin
 >
 > --
 > To unsubscribe, send a message with 'unsubscribe linux-mm' in
 > the body to majordomo@kvack.org.  For more info on Linux MM,
 > see: http://www.linux-mm.org/
 >
 >
 >
 >



-- 
Timur Tabi
Interactive Silicon


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
