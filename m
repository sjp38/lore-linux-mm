Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iABJaxAD317142
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 14:36:59 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iABJb2b4147530
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 12:37:02 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iABJaxLQ026496
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 12:36:59 -0700
Subject: Re: [Fwd: Page allocator doubt]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <4193BD07.5010100@tteng.com.br>
References: <41937940.9070001@tteng.com.br>
	 <1100200247.932.1145.camel@localhost>  <4193BD07.5010100@tteng.com.br>
Content-Type: text/plain
Message-Id: <1100201816.7883.22.camel@localhost>
Mime-Version: 1.0
Date: Thu, 11 Nov 2004 11:36:56 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luciano A. Stertz" <luciano@tteng.com.br>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-11-11 at 11:27, Luciano A. Stertz wrote:
> 	But... are they allocated to me, even with page_count zeroed? Do I need 
> to do get_page on the them? Sorry if it's a too lame question, but I 
> still didn't understand and found no place to read about this.

Do you see anywhere in the page allocator where it does a loop like
yours?

        for (i = 1; i< 1<<order; i++)
		get_page(page + i);

When you do a multi-order allocation, the first page represents the
whole group and they're treated as a whole.  As you've noticed, breaking
them up requires a little work.

Why don't you post all of the code that you're using so that we can tell
what you're doing?  There might be a better way.  Drivers probably
shouldn't be putting stuff in the page cache all by themselves.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
