Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j2SLNYvC020739
	for <linux-mm@kvack.org>; Mon, 28 Mar 2005 16:23:34 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2SLNV6J092924
	for <linux-mm@kvack.org>; Mon, 28 Mar 2005 16:23:34 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j2SLNUiR032112
	for <linux-mm@kvack.org>; Mon, 28 Mar 2005 16:23:30 -0500
Subject: Re: [PATCH 0/4] sparsemem intro patches
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050319193345.GE1504@openzaurus.ucw.cz>
References: <1110834883.19340.47.camel@localhost>
	 <20050319193345.GE1504@openzaurus.ucw.cz>
Content-Type: text/plain
Date: Mon, 28 Mar 2005 13:23:25 -0800
Message-Id: <1112045005.2087.38.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2005-03-19 at 20:33 +0100, Pavel Machek wrote:
> > Three of these are i386-only, but one of them reorganizes the macros
> > used to manage the space in page->flags, and will affect all platforms.
> > There are analogous patches to the i386 ones for ppc64, ia64, and
> > x86_64, but those will be submitted by the normal arch maintainers.
> > 
> > The combination of the four patches has been test-booted on a variety of
> > i386 hardware, and compiled for ppc64, i386, and x86-64 with about 17
> > different .configs.  It's also been runtime-tested on ia64 configs (with
> > more patches on top).
> 
> Could you try swsusp on i386, too?

Runtime, or just compiling?  

Have you noticed a real problem?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
