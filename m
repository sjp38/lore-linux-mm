Received: by nf-out-0910.google.com with SMTP id h3so3971594nfh.6
        for <linux-mm@kvack.org>; Mon, 28 Apr 2008 11:30:34 -0700 (PDT)
From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: 2.6.25-mm1: Failing to probe IDE interface
Date: Mon, 28 Apr 2008 20:44:34 +0200
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <20080428164235.GA29229@csn.ul.ie>
In-Reply-To: <20080428164235.GA29229@csn.ul.ie>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200804282044.34783.bzolnier@gmail.com>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Monday 28 April 2008, Mel Gorman wrote:
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

Please try reverting ide-fix-hwif-s-initialization.patch first - it has
already been dropped from IDE tree because people were reporting problems
similar to the one encountered by you.

Thanks,
Bart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
