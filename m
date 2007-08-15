Date: Wed, 15 Aug 2007 12:59:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070815125920.GD3406@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0708151259230.7326@schroedinger.engr.sgi.com>
References: <20070813225841.GG3406@bingen.suse.de>
 <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com>
 <20070813230801.GH3406@bingen.suse.de> <Pine.LNX.4.64.0708131536340.29946@schroedinger.engr.sgi.com>
 <20070813234322.GJ3406@bingen.suse.de> <Pine.LNX.4.64.0708131553050.30626@schroedinger.engr.sgi.com>
 <20070814000041.GL3406@bingen.suse.de> <20070814002223.2d8d42c5@the-village.bc.nu>
 <20070814001441.GN3406@bingen.suse.de> <20070815113749.GA5862@linux-mips.org>
 <20070815125920.GD3406@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ralf Baechle <ralf@linux-mips.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2007, Andi Kleen wrote:

> BTW I suspect this is true for some other GFP_DMA usages too.
> Some driver writers seem to confuse it with the PCI DMA
> APIs or believe it is always needed for them.

See especially ARM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
