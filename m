Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7VGe5DD028339
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 12:40:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7VGe5bp497756
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 10:40:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7VGe5xU009206
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 10:40:05 -0600
Subject: Re: Selective swap out of processes
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <49e98fc50708301650q611f9b0fi762f9c5d8d5fae01@mail.gmail.com>
References: <1188320070.11543.85.camel@bastion-laptop>
	 <46D4DBF7.7060102@yahoo.com.au>  <1188383827.11270.36.camel@bastion-laptop>
	 <1188410818.9682.2.camel@bastion-laptop>  <46D66E31.9030202@yahoo.com.au>
	 <49e98fc50708301641h16b8dc6fsce7a4b4dadf9ec60@mail.gmail.com>
	 <49e98fc50708301650q611f9b0fi762f9c5d8d5fae01@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 31 Aug 2007 09:40:04 -0700
Message-Id: <1188578404.28903.258.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jcabezas@ac.upc.edu
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Isn't the whole point of get_user_pages() so that the kernel doesn't
mess with those pages, and the driver or whatever can have free reign?

Seems to me that you're pinning the pages with get_user_pages(), then
trying to get the kernel to swap them out.  Not a good idea. ;)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
