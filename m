Received: from google.com (biro.corp.google.com [10.3.4.241])
	by 216-239-45-4.google.com (8.12.3/8.12.3) with ESMTP id h2BKeTN8015210
	for <linux-mm@kvack.org>; Tue, 11 Mar 2003 12:40:29 -0800
Message-ID: <3E6E49BD.1050701@google.com>
Date: Tue, 11 Mar 2003 12:40:29 -0800
From: Ross Biro <rossb@google.com>
MIME-Version: 1.0
Subject: [Fwd: [BUG][2.4.18+] kswapd assumes swapspace exists]
Content-Type: multipart/mixed;
 boundary="------------000601040005060607020103"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000601040005060607020103
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I posted this to the LKML and got no response.  There is definitely an 
MM bug here.  My test program (should be attached) has run over 330 
times in a row with the change while it rarely made more than twice with 
out the change.

Please CC me on any feedback.

    Ross

--------------000601040005060607020103
Content-Type: message/rfc822;
 name="[BUG][2.4.18+] kswapd assumes swapspace exists"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="[BUG][2.4.18+] kswapd assumes swapspace exists"



--------------000601040005060607020103--
