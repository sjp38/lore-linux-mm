Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [ofa-general] Re: Demand paging for memory regions
Date: Fri, 15 Feb 2008 15:14:41 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77030E2657@nekter>
In-Reply-To: <Pine.LNX.4.64.0802151158560.14517@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>  <ada3arzxgkz.fsf_-_@cisco.com>  <47B2174E.5000708@opengridcomputing.com>  <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>  <adazlu5vlub.fsf@cisco.com>  <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>  <47B45994.7010805@opengridcomputing.com>  <Pine.LNX.4.64.0802141137140.500@schroedinger.engr.sgi.com>  <469958e00802141217i3a3d16a1k1232d69b8ba54471@mail.gmail.com>  <Pine.LNX.4.64.0802141219110.1041@schroedinger.engr.sgi.com> <469958e00802141443g33448abcs3efa6d6c4aec2b56@mail.gmail.com> <Pine.LNX.4.64.0802141445570.3298@schroedinger.engr.sgi.com> <78C9135A3D2ECE4B8162EBDCE82CAD77030E2456@nekter> <Pine.LNX.4.64.0802141836070.4898@schroedinger.engr.sgi.com> <78C9135A3D2ECE4B8162EBDCE82CAD77030E25BA@nekter> <Pine.LNX.4.64.0802151044310.12890@schroedinger.engr.sgi.com> <78C9135A3D2ECE4B8162EBDCE82CAD77030E25F1@nekter> <Pine.LNX.4.64.0802151158560.14517@schroedinger.engr.sgi.com>
From: "Caitlin Bestler" <Caitlin.Bestler@neterion.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote
> 
> > Merely mlocking pages deals with the end-to-end RDMA semantics.
> > What still needs to be addressed is how a fastpath interface
> > would dynamically pin and unpin. Yielding pins for short-term
> > suspensions (and flushing cached translations) deals with the
> > rest. Understanding the range of support that existing devices
> > could provide with software updates would be the next step if
> > you wanted to pursue this.
> 
> That is addressed on the VM level by the mmu_notifier which started
> this whole thread. The RDMA layers need to subscribe to this notifier
> and then do whatever the hardware requires to unpin and pin memory.
> I can only go as far as dealing with the VM layer. If you have any
> issues there I'd be glad to help.

There isn't much point in the RDMA layer subscribing to mmu
notifications
if the specific RDMA device will not be able to react appropriately when
the notification occurs. I don't see how you get around needing to know
which devices are capable of supporting page migration (via
suspend/resume
or other mechanisms) and which can only respond to a page migration by
aborting connections.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
