Message-ID: <3E6E88F8.5050306@google.com>
Date: Tue, 11 Mar 2003 17:10:16 -0800
From: Ross Biro <rossb@google.com>
MIME-Version: 1.0
Subject: Re: [Fwd: [BUG][2.4.18+] kswapd assumes swapspace exists]
References: <3E6E49BD.1050701@google.com> <20030311162922.373a2414.akpm@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>There's no point in bringing these pages onto the inactive list at all. 
>Suggest you look at keeping them on the active list in refill_inactive().
>  
>

Good point.  I will add that to my changes.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
