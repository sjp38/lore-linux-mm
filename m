Message-ID: <3C3A53EF.7010402@rcn.com.hk>
Date: Tue, 08 Jan 2002 10:05:35 +0800
From: David Chow <davidchow@rcn.com.hk>
MIME-Version: 1.0
Subject: 2.4.17 VM question
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dear all,

 From 2.4.14, the SetPageDecrAfter() in mm.h is gone.... also it is now 
not called in rw_swap_page_base() in paeg_io.c . The PG_decr_after (5) 
flag is now dissappeared. Now the 5 is replaced with something called 
PG_unused in mm.h . What's the meaning of both? Also the 
rw_swap_page_base() now doesn't check rw==WRITE and where does the WRITE 
handles? Thanks.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
