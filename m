Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <Pine.LNX.4.44.0210222220480.22282-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0210222220480.22282-100000@localhost.localdomain>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 21:38:08 +0100
Message-Id: <1035319088.31873.149.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@digeo.com>, Christoph Hellwig <hch@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2002-10-22 at 21:27, Ingo Molnar wrote:
> limit. I do not realistically believe that any 32-bit x86 box that is
> connected to a larger than 2 TB disk array cannot possibly run a PAE
> kernel. Just like you need PAE for more than 4 GB physical RAM. I find it
> a bit worrisome that 32-bit x86 ptes can only support up to 4 GB of
> physical RAM, but such is life :-)

Actually I know a few. 2Tb is cheap - its one pci controller and eight
ide disks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
