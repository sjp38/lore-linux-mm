Date: Wed, 13 Feb 2008 10:31:18 -0800
From: mark gross <mgross@linux.intel.com>
Subject: Re: [PATCH]intel-iommu batched iotlb flushes
Message-ID: <20080213183118.GB1162@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20080212085256.GF5750@rhun.haifa.ibm.com> <20080212.010006.255202479.davem@davemloft.net> <20080212155448.GC27490@linux.intel.com> <20080212.154630.241691261.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080212.154630.241691261.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: muli@il.ibm.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2008 at 07:54:48AM -0800, David Miller wrote:
> > Something could be done:
> > we could enable drivers to have DMA-pools they manage that get mapped
> > and are re-used.
> > 
> > I would rather the DMA-pools be tied to PID's that way any bad behavior
> > would be limited to the address space of the process using the device.
> > I haven't thought about how hard this would be to do but it would be
> > nice.  I think this could be tricky.
> 
> Yes, this is a good idea especially for networking.
> 
> For transmit on 10GB links the IOMMU setup is near the top
> of the profiles.

true.
 
> What a driver could do is determine the maximum number of
> IOMMU pages it could need to map one maximally sized packet.
> So then it allocates enough space for all such entries in
> it's TX ring.
> 
> This eliminates the range allocation from the transmit path.
> All that's left is "remap DMA range X to scatterlist Y"
> 
> And yes it would be nice to have dma_map_skb() type interfaces
> so that we don't walk into the IOMMU code N times per packet.


/me starts looking more closely at how this could be done...

--mgross
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
