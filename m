From: Andi Kleen <ak@suse.de>
Subject: Re: More thoughts on getting rid of ZONE_DMA
Date: Sat, 23 Sep 2006 02:37:44 +0200
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com> <200609230134.45355.ak@suse.de> <Pine.LNX.4.64.0609221724580.10484@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609221724580.10484@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609230237.44132.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 23 September 2006 02:25, Christoph Lameter wrote:
> Another solution may be to favor high adresses in the page allocator?

We used to do that, but it got changed because IO request merging without
IOMMU works much better if you start low and go up instead of the other
way round.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
