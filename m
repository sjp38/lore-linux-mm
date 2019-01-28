From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: use generic DMA mapping code in powerpc V4
Date: Mon, 28 Jan 2019 17:22:56 +0100
Message-ID: <20190128162256.GA11737@lst.de>
References: <e11e61b1-6468-122e-fc2b-3b3f857186bb@xenosoft.de>
	<f39d4fc6-7e4e-9132-c03f-59f1b52260e0@xenosoft.de>
	<b9e5e081-a3cc-2625-4e08-2d55c2ba224b@xenosoft.de>
	<20190119130222.GA24346@lst.de> <20190119140452.GA25198@lst.de>
	<bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de>
	<8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de>
	<4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de>
	<1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de>
	<20190128070422.GA2772@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20190128070422.GA2772-jcswGhMUV9g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Zigotzky <chzigotzky-KCoaydhb8eAb1SvskN2V4Q@public.gmane.org>
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Darren Stevens <darren-YHtdit1eIT3easaKlIn9Lw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Julian Margetson <runaway-zqC88Q5qmK4@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
List-Id: linux-mm.kvack.org

On Mon, Jan 28, 2019 at 08:04:22AM +0100, Christoph Hellwig wrote:
> On Sun, Jan 27, 2019 at 02:13:09PM +0100, Christian Zigotzky wrote:
> > Christoph,
> >
> > What shall I do next?
> 
> I'll need to figure out what went wrong with the new zone selection
> on powerpc and give you another branch to test.

Can you try the new powerpc-dma.6-debug.2 branch:

    git://git.infradead.org/users/hch/misc.git powerpc-dma.6-debug.2

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6-debug.2
