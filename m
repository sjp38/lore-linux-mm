Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i7H5G5rH012757
	for <linux-mm@kvack.org>; Mon, 16 Aug 2004 22:16:06 -0700 (PDT)
Date: Mon, 16 Aug 2004 22:15:51 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: [Lhms-devel] Making hotremovable attribute with memory section[0/4]
In-Reply-To: <1092702436.21359.3.camel@localhost.localdomain>
References: <1092699350.1822.43.camel@nighthawk> <1092702436.21359.3.camel@localhost.localdomain>
Message-Id: <20040816214017.77A3.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

Hello.

> On Maw, 2004-08-17 at 00:35, Dave Hansen wrote:
> > In any case, the question of the day is, does anyone have any
> > suggestions on how to create 2 separate pools for pages: one
> > representing hot-removable pages, and the other pages that may not be
> > removed?
> 
> How do you define the split. There are lots of circumstances where user
> pages can be pinned for a long (near indefinite) period of time and used
> for DMA.

Basically, kernel have to wait of completion of I/O.

> Consider
> - Video capture
> - AGP Gart
> - AGP based framebuffer (intel i8/9xx)

I didn't consider deeply about this, because usually
enterprise server doesn't need Video capture feature or AGP.
It is usually controlled from other machine.

If it is really necessary, kernel might have to wait 
I/O completion or driver modification is necessary.


> - O_DIRECT I/O

I can use page remmaping method by Iwamoto-san.
(See: http://people.valinux.co.jp/~iwamoto/mh.html#remap)
I guess that many case can be saved by this.

> There are also things like cluster interconnects, sendfile and the like
> involved here.

In sendfile case, kernel will wait too. Sooner or later, it will be
timeout.

Thank you for your comment.
Bye.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
