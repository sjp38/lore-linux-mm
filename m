Date: Fri, 24 Dec 2004 09:02:10 -0800
From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Prezeroing V2 [2/4]: add second parameter to clear_page() for
 all arches
Message-Id: <20041224090210.4bbe11a8.davem@davemloft.net>
In-Reply-To: <20041224162745.GA1178@elf.ucw.cz>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
	<41C20E3E.3070209@yahoo.com.au>
	<Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
	<Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
	<20041224083337.GA1043@openzaurus.ucw.cz>
	<Pine.LNX.4.58.0412240818030.6505@schroedinger.engr.sgi.com>
	<20041224162745.GA1178@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: clameter@sgi.com, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Dec 2004 17:27:45 +0100
Pavel Machek <pavel@ucw.cz> wrote:

> I do not know what Andi said, but having clear_page clearing two
> page*s* seems wrong to me.

It's represented by a single top-level page struct regardless
of it's order, so in that sense it's indeed a single page
no matter it's order.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
