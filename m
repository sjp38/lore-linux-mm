Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j5TIhrs3004994
	for <linux-mm@kvack.org>; Wed, 29 Jun 2005 14:43:53 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j5TIhrKI258922
	for <linux-mm@kvack.org>; Wed, 29 Jun 2005 14:43:53 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j5TIhqma031738
	for <linux-mm@kvack.org>; Wed, 29 Jun 2005 14:43:52 -0400
Subject: Re: [patch 2] mm: speculative get_page
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050629163132.GB13336@elf.ucw.cz>
References: <42BF9CD1.2030102@yahoo.com.au> <42BF9D67.10509@yahoo.com.au>
	 <42BF9D86.90204@yahoo.com.au> <42C14662.40809@shadowen.org>
	 <42C14D93.7090303@yahoo.com.au> <1119974566.14830.111.camel@localhost>
	 <20050629163132.GB13336@elf.ucw.cz>
Content-Type: text/plain
Date: Wed, 29 Jun 2005 11:43:36 -0700
Message-Id: <1120070616.12143.4.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andy Whitcroft <apw@shadowen.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-06-29 at 18:31 +0200, Pavel Machek wrote:
> > > I think there are a a few ways that bits can be reclaimed if we
> > > start digging. swsusp uses 2 which seems excessive though may be
> > > fully justified. 
> > 
> > They (swsusp) actually don't need the bits at all until suspend-time, at
> > all.  Somebody coded up a "dynamic page flags" patch that let them kill
> > the page->flags use, but it didn't really go anywhere.  Might be nice if
> > someone dug it up.  I probably have a copy somewhere.
> 
> Unfortunately that patch was rather ugly :-(.

Do you think the idea was ugly, or just the implementation?  Is there
something that you'd rather see?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
