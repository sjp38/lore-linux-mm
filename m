From: Andi Kleen <ak@suse.de>
Subject: Re: More thoughts on getting rid of ZONE_DMA
Date: Sun, 24 Sep 2006 09:26:40 +0200
References: <Pine.LNX.4.64.0609212052280.4736@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0609231907360.16435@schroedinger.engr.sgi.com> <4515EF28.9000805@mbligh.org>
In-Reply-To: <4515EF28.9000805@mbligh.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609240926.41208.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Christoph Lameter <clameter@sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@google.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@steeleye.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> If it's the 16MB DMA window for ia32 we're talking about, wouldn't
> it be easier just to remove it from the fallback lists? (assuming
> you have at least 128MB of memory or something, blah, blah). Saves
> doing migration later.

That is essentially already the case because the mm has special
heuristics to preserve lower zones. Usually those tend to keep the
16MB mostly free unless you really use GFP_DMA.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
