Date: Fri, 17 Dec 2004 01:51:56 +0100 (CET)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [patch] [RFC] make WANT_PAGE_VIRTUAL a config option
In-Reply-To: <1103244171.13614.2525.camel@localhost>
Message-ID: <Pine.LNX.4.61.0412170150080.793@scrub.home>
References: <E1Cf3bP-0002el-00@kernel.beaverton.ibm.com>
 <Pine.LNX.4.61.0412170133560.793@scrub.home> <1103244171.13614.2525.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, geert@linux-m68k.org, ralf@linux-mips.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 16 Dec 2004, Dave Hansen wrote:

> > Why do you want to move struct page into a separate file?
> 
> Circular header dependencies suck :)

Could you explain a bit more, what exactly the problem is?

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
