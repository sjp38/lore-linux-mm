Date: Wed, 16 Aug 2000 20:53:56 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Message-ID: <20000816205356.N19260@redhat.com>
References: <399A4FE4.FA5C397A@augan.com> <200008161713.KAA54085@google.engr.sgi.com> <20000816192012.K19260@redhat.com> <200008161824.LAA09497@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200008161824.LAA09497@pizda.ninka.net>; from davem@redhat.com on Wed, Aug 16, 2000 at 11:24:23AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: sct@redhat.com, kanoj@google.engr.sgi.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com, alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Aug 16, 2000 at 11:24:23AM -0700, David S. Miller wrote:
> 
> Which is one of the reasons I wish the bounce buffer stuff went into
> the place it belongs, behind the pci_dma API.  If we move to a
> page+offset model for drivers, we could do exactly this and also
> handle cases like ix86 PAE.

Fine --- it is pretty easy to generate a scatterlist from a kiobuf so
that drivers using a kiovec API can use the existing pci_dma support.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
