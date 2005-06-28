Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5SG33Ww092078
	for <linux-mm@kvack.org>; Tue, 28 Jun 2005 12:03:04 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5SG33cC157608
	for <linux-mm@kvack.org>; Tue, 28 Jun 2005 10:03:03 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5SG32Fi010390
	for <linux-mm@kvack.org>; Tue, 28 Jun 2005 10:03:02 -0600
Subject: Re: [patch 2] mm: speculative get_page
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <42C14D93.7090303@yahoo.com.au>
References: <42BF9CD1.2030102@yahoo.com.au> <42BF9D67.10509@yahoo.com.au>
	 <42BF9D86.90204@yahoo.com.au> <42C14662.40809@shadowen.org>
	 <42C14D93.7090303@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 28 Jun 2005 09:02:46 -0700
Message-Id: <1119974566.14830.111.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-06-28 at 23:16 +1000, Nick Piggin wrote:
> I think there are a a few ways that bits can be reclaimed if we
> start digging. swsusp uses 2 which seems excessive though may be
> fully justified. 

They (swsusp) actually don't need the bits at all until suspend-time, at
all.  Somebody coded up a "dynamic page flags" patch that let them kill
the page->flags use, but it didn't really go anywhere.  Might be nice if
someone dug it up.  I probably have a copy somewhere.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
