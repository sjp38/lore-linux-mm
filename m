Date: Tue, 8 Jul 2003 01:55:58 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm2 + nvidia (and others)
Message-ID: <20030708085558.GG15452@holomorphy.com>
References: <1057590519.12447.6.camel@sm-wks1.lan.irkk.nu> <1057647818.5489.385.camel@workshop.saharacpt.lan> <20030708072604.GF15452@holomorphy.com> <200307081051.41683.schlicht@uni-mannheim.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200307081051.41683.schlicht@uni-mannheim.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Schlichter <schlicht@uni-mannheim.de>
Cc: Martin Schlemmer <azarah@gentoo.org>, Andrew Morton <akpm@osdl.org>, smiler@lanil.mine.nu, KML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 08, 2003 at 10:51:39AM +0200, Thomas Schlichter wrote:
> Well, the NVIDIA patches are at
>    http://www.minion.de/nvidia.html
> but I don't know about the VMWARE patches...

Thanks. I'll grab that and start maintaining highpmd updates for it.


On Tue, Jul 08, 2003 at 10:51:39AM +0200, Thomas Schlichter wrote:
> Btw, what do you think about the idea of exporting the follow_pages()
> function from mm/memory.c to kernel modules? So this could be used
> for modules compiled for 2.[56] kernels and the old way just for 2.4
> kernels...

I don't really have an opinion on it, but it's not my call.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
