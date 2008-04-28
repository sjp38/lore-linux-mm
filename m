Date: Mon, 28 Apr 2008 09:59:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-mm1: Failing to probe IDE interface
Message-Id: <20080428095924.3b7dfb96.akpm@linux-foundation.org>
In-Reply-To: <20080428164235.GA29229@csn.ul.ie>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
	<20080428164235.GA29229@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, bzolnier@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 28 Apr 2008 17:42:36 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> An old T21 is failing to boot and the relevant message appears to be
> 
> [    1.929536] Probing IDE interface ide0...
> [   36.939317] ide0: Wait for ready failed before probe !
> [   37.502676] ide0: DISABLED, NO IRQ
> [   37.506356] ide0: failed to initialize IDE interface
> 
> The owner of ide-mm-ide-add-struct-ide_io_ports-take-2.patch with the
> "DISABLED, NO IRQ" message is cc'd. I've attached the config, full boot log
> and lspci -v for the machine in question. I'll start reverting some of the
> these patches to see if ide-mm-ide-add-struct-ide_io_ports-take-2.patch
> is really the culprit.

ide-mm-ide-add-struct-ide_io_ports-take-2.patch is now in mainline so a
quicky confirmation would be to test Linus's tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
