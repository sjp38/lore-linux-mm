Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j37FUZ4I631756
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 11:30:35 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j37FUVFP197282
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 09:30:34 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j37FUVdm028313
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 09:30:31 -0600
Subject: Re: [PATCH 1/4] create mm/Kconfig for arch-independent memory
	options
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0504070219160.15339@scrub.home>
References: <E1DIViE-0006Kf-00@kernel.beaverton.ibm.com>
	 <42544D7E.1040907@linux-m68k.org> <1112821319.14584.28.camel@localhost>
	 <Pine.LNX.4.61.0504070133380.25131@scrub.home>
	 <1112831857.14584.43.camel@localhost>
	 <Pine.LNX.4.61.0504070219160.15339@scrub.home>
Content-Type: text/plain
Date: Thu, 07 Apr 2005 08:30:24 -0700
Message-Id: <1112887825.14584.59.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-04-07 at 02:30 +0200, Roman Zippel wrote:
> I was hoping for this too, in the meantime can't you simply make it a 
> suboption of DISCONTIGMEM? So an extra option is only visible when it's 
> enabled and most people can ignore it completely by just disabling a 
> single option.

That's reasonable, except that SPARSEMEM doesn't strictly have anything
to do with DISCONTIG.

How about a menu that's hidden under CONFIG_EXPERIMENTAL?

> > I'm not opposed to creating some better help text for those things, I'm
> > just not sure that we really need it, or that it will help end users get
> > to the right place.  I guess more explanation never hurt anyone.
> 
> Some basic explanation with a link for more information can't hurt.

I'll see what I can come up with.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
