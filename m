Date: Tue, 17 Aug 2004 10:58:56 +0100
From: Dave Jones <davej@redhat.com>
Subject: Re: [Lhms-devel] Making hotremovable attribute with memory section[0/4]
Message-ID: <20040817095856.GA19243@redhat.com>
References: <1092699350.1822.43.camel@nighthawk> <1092702436.21359.3.camel@localhost.localdomain> <20040816214017.77A3.YGOTO@us.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040816214017.77A3.YGOTO@us.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Dave Hansen <haveblue@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 16, 2004 at 10:15:51PM -0700, Yasunori Goto wrote:
 > > Consider
 > > - Video capture
 > > - AGP Gart
 > > - AGP based framebuffer (intel i8/9xx)
 > 
 > I didn't consider deeply about this, because usually
 > enterprise server doesn't need Video capture feature or AGP.

AMD64's IOMMU is implemented using the AGP GART.
This feature is certainly used in server environments.

		Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
