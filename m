Subject: Re: Fw: [Lhms-devel] Making hotremovable attribute with memory
	section[0/4]
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1092699350.1822.43.camel@nighthawk>
References: <20040816153613.E6F7.YGOTO@us.fujitsu.com>
	 <1092699350.1822.43.camel@nighthawk>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1092702436.21359.3.camel@localhost.localdomain>
Mime-Version: 1.0
Date: Tue, 17 Aug 2004 01:27:23 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Yasunori Goto <ygoto@us.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

On Maw, 2004-08-17 at 00:35, Dave Hansen wrote:
> In any case, the question of the day is, does anyone have any
> suggestions on how to create 2 separate pools for pages: one
> representing hot-removable pages, and the other pages that may not be
> removed?

How do you define the split. There are lots of circumstances where user
pages can be pinned for a long (near indefinite) period of time and used
for DMA.

Consider
- Video capture
- AGP Gart
- AGP based framebuffer (intel i8/9xx)
- O_DIRECT I/O

There are also things like cluster interconnects, sendfile and the like
involved here.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
