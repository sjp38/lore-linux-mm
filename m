Date: Tue, 7 Nov 2006 11:15:31 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/3] add dev_to_node()
Message-ID: <20061107101531.GB28970@lst.de>
References: <20061030141501.GC7164@lst.de> <20061030.143357.130208425.davem@davemloft.net> <20061104225629.GA31437@lst.de> <20061104230648.GB640@redhat.com> <20061104235323.GA1353@lst.de> <20061107062536.GA3729@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061107062536.GA3729@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: Christoph Hellwig <hch@lst.de>, Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, "Benzi Galili (Benzi@ScaleMP.com)" <benzi@scalemp.com>, "Shai Fultheim (Shai@scalex86.org)" <shai@scalex86.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 06, 2006 at 10:25:36PM -0800, Ravikiran G Thirumalai wrote:
> On Sun, Nov 05, 2006 at 12:53:23AM +0100, Christoph Hellwig wrote:
> > On Sat, Nov 04, 2006 at 06:06:48PM -0500, Dave Jones wrote:
> > > On Sat, Nov 04, 2006 at 11:56:29PM +0100, Christoph Hellwig wrote:
> > > 
> > > This will break the compile for !NUMA if someone ends up doing a bisect
> > > and lands here as a bisect point.
> > > 
> > > You introduce this nice wrapper..
> > 
> > The dev_to_node wrapper is not enough as we can't assign to (-1) for
> > the non-NUMA case.  So I added a second macro, set_dev_node for that.
> > 
> > The patch below compiles and works on numa and non-NUMA platforms.
> > 
> > 
> 
> Hi Christoph,
> dev_to_node does not work as expected on x86_64 (and i386).  This is because
> node value returned by pcibus_to_node is initialized after a struct device
> is created with current x86_64 code.
> 
> We need the node value initialized before the call to pci_scan_bus_parented,
> as the generic devices are allocated and initialized
> off pci_scan_child_bus, which gets called from pci_scan_bus_parented
> The following patch does that using "pci_sysdata" introduced by the PCI
> domain patches in -mm.

A nice, that some non-cell folks actually care for this patch.  As far
as my x86_64 pci code knowledge is concerned that patch look fine to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
