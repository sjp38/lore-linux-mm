Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBKEnNSn006016
	for <linux-mm@kvack.org>; Mon, 20 Dec 2004 09:49:23 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBKEnN5X272464
	for <linux-mm@kvack.org>; Mon, 20 Dec 2004 09:49:23 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBKEnM6u011765
	for <linux-mm@kvack.org>; Mon, 20 Dec 2004 09:49:22 -0500
Subject: Re: [patch] [RFC] make WANT_PAGE_VIRTUAL a config option
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0412180020220.793@scrub.home>
References: <E1Cf3bP-0002el-00@kernel.beaverton.ibm.com>
	 <Pine.LNX.4.61.0412170133560.793@scrub.home>
	 <1103244171.13614.2525.camel@localhost>
	 <Pine.LNX.4.61.0412170150080.793@scrub.home>
	 <1103246050.13614.2571.camel@localhost>
	 <Pine.LNX.4.61.0412170256500.793@scrub.home>
	 <1103257482.13614.2817.camel@localhost>
	 <Pine.LNX.4.61.0412171132560.793@scrub.home>
	 <1103299179.13614.3551.camel@localhost>
	 <Pine.LNX.4.61.0412171818090.793@scrub.home>
	 <1103320106.7864.6.camel@localhost>
	 <Pine.LNX.4.61.0412180020220.793@scrub.home>
Content-Type: text/plain
Message-Id: <1103554150.11069.104.camel@localhost>
Mime-Version: 1.0
Date: Mon, 20 Dec 2004 06:49:10 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, geert@linux-m68k.org, ralf@linux-mips.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-12-17 at 16:52, Roman Zippel wrote:
> In your case don't put the inline functions into asm/mmzone.h and we 
> should merge the various definition into fewer header files.

OK, I'm sold.  

But, what do you think we should do about the current #defines in
asm/mmzone.h, like pfn_to_page()?  Would it be feasible to put them in
another header that can use proper functions?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
