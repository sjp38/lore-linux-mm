Date: Wed, 1 Jun 2005 18:34:21 -0700
From: Grant Grundler <iod00d@hp.com>
Subject: Re: [RFC] vmalloc with the ability to specify a node
Message-ID: <20050602013421.GS25321@esmail.cup.hp.com>
References: <Pine.LNX.4.62.0506011551240.10915@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0506011551240.10915@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 01, 2005 at 03:52:42PM -0700, Christoph Lameter wrote:
> I was surprised to see that some drivers allocate memory structures
> using vmalloc.

It's drivers I care about. :^(

grundler@gsyprf3:/usr/src/linux-2.6$ fgrep vmalloc drivers/net/*/*c
drivers/net/e1000/e1000.mod.c:  { 0xd6ee688f, "vmalloc" },
drivers/net/e1000/e1000_main.c: txdr->buffer_info = vmalloc(size);
drivers/net/e1000/e1000_main.c: rxdr->buffer_info = vmalloc(size);
drivers/net/ixgb/ixgb.mod.c:    { 0xd6ee688f, "vmalloc" },
drivers/net/ixgb/ixgb_main.c:   txdr->buffer_info = vmalloc(size);
drivers/net/ixgb/ixgb_main.c:   rxdr->buffer_info = vmalloc(size);
grundler@gsyprf3:/usr/src/linux-2.6$ fgrep vmalloc drivers/scsi/*/*c
drivers/scsi/qla2xxx/qla2xxx.mod.c:     { 0xd6ee688f, "vmalloc" },
drivers/scsi/qla2xxx/qla_os.c:#include <linux/vmalloc.h>
drivers/scsi/qla2xxx/qla_os.c:                  ha->fw_dump_buffer = (char *)vmalloc(dump_size);

Could someone explain to me why this is a bad thing on NUMA machines?
I assume it has something to do with mem locality and how the memory
is used.

> Only tested in a limited way. Boots fine. Is this worth doing?

Any difference in performance?
Any clue why it matters?

grant
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
