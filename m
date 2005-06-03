Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j53Keskh001955
	for <linux-mm@kvack.org>; Fri, 3 Jun 2005 16:40:54 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j53KesOp246376
	for <linux-mm@kvack.org>; Fri, 3 Jun 2005 16:40:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j53Kerub022167
	for <linux-mm@kvack.org>; Fri, 3 Jun 2005 16:40:53 -0400
Subject: Re: defrag memory
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <6934efce0506031319a2bfbaf@mail.gmail.com>
References: <6934efce0505261214345a609f@mail.gmail.com>
	 <1117141158.27082.22.camel@localhost>
	 <6934efce0506031319a2bfbaf@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 03 Jun 2005 13:40:46 -0700
Message-Id: <1117831246.23518.7.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-06-03 at 13:19 -0700, Jared Hulbert wrote:
> > There are a few efforts (external patches) to decrease fragmentation to
> > allow for more ease in removing memory, or allocating larger physically
> > contiguous areas, but nothing in mainline or -mm.
> 
> Can you list me some key words to google for?

Try: memory migration linux

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
