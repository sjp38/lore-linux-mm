Subject: Re: Problem with mmap( ) in linux ppc!
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20030310115059.2862dfb1.anand@rttsindia.com>
References: <20030310115059.2862dfb1.anand@rttsindia.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1047286101.19500.19.camel@zion.wanadoo.fr>
Mime-Version: 1.0
Date: 10 Mar 2003 09:48:21 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anand Gurumurthy <anand@rttsindia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-03-10 at 07:20, Anand Gurumurthy wrote:
> Hi,
> 	We have a driver for a communication card which has memory mapped IO
> We are using redhat 2.2.14 kernel on intel p3 processor. The driver has an
> mmap entry point to map device memory into the user space using remap_page_range().
> It works fine with intel P3. When we try to use the same driver with ppc linux 2.2.17
> kernel, the mmap system call does not map the proper device memory.Is there anything
> extra  required for using mmap with ppc? Please help me with your suggestions.

You may have some remapping going on the bus, it depends which PPC machine you
are using (how it's host bridge is confiured). 2.2 kernel didn't deal with
that as transparently as 2.4 do. Just a guess... I don't know much about
your HW

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
