Date: Tue, 22 Oct 2002 22:42:37 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
In-Reply-To: <1035319088.31873.149.camel@irongate.swansea.linux.org.uk>
Message-ID: <Pine.LNX.4.44.0210222237180.22860-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andrew Morton <akpm@digeo.com>, Christoph Hellwig <hch@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 Oct 2002, Alan Cox wrote:

> Actually I know a few. 2Tb is cheap - its one pci controller and eight
> ide disks.

2Tb should still work. And to get to the 16 TB limit you'd have to
recompile with PAE. It costs some (rather limited) RAM overhead and some
fork() overhead. I think ext2/ext3fs's current 2Tb/4Tb limit is a much
bigger problem, you cannot compile around that - are there any patches in
fact that lift that limit? (well, one solution is to use another
filesystem.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
