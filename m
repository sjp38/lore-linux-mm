Received: from [192.168.0.2] ([217.145.9.188])
	by mail3.euroweb.net.mt (8.11.6/8.11.6) with ESMTP id j2VHgki12005
	for <linux-mm@kvack.org>; Thu, 31 Mar 2005 19:42:46 +0200
Message-ID: <424C38E2.4080904@euroweb.net.mt>
Date: Thu, 31 Mar 2005 19:52:34 +0200
From: "Josef E. Galea" <josefeg@euroweb.net.mt>
MIME-Version: 1.0
Subject: Virtual memory
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

Can someone point me to some document that explains how swapping in the 
2.6 kernel series work. Basically I would like to know how the kernel 
`decides' to swap out and which function chooses the pages that should 
be swapped (like the try_to_swap_out() function in the 2.4 kernel series).

Thanks
Josef Galea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
