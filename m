Date: Fri, 15 Feb 2008 10:45:55 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77030E25BA@nekter>
Message-ID: <Pine.LNX.4.64.0802151044310.12890@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
 <ada3arzxgkz.fsf_-_@cisco.com>  <47B2174E.5000708@opengridcomputing.com>
 <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>
 <adazlu5vlub.fsf@cisco.com>  <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>
  <47B45994.7010805@opengridcomputing.com>  <Pine.LNX.4.64.0802141137140.500@schroedinger.engr.sgi.com>
  <469958e00802141217i3a3d16a1k1232d69b8ba54471@mail.gmail.com>
 <Pine.LNX.4.64.0802141219110.1041@schroedinger.engr.sgi.com>
 <469958e00802141443g33448abcs3efa6d6c4aec2b56@mail.gmail.com>
 <Pine.LNX.4.64.0802141445570.3298@schroedinger.engr.sgi.com>
 <78C9135A3D2ECE4B8162EBDCE82CAD77030E2456@nekter>
 <Pine.LNX.4.64.0802141836070.4898@schroedinger.engr.sgi.com>
 <78C9135A3D2ECE4B8162EBDCE82CAD77030E25BA@nekter>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Caitlin Bestler <Caitlin.Bestler@neterion.com>
Cc: linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2008, Caitlin Bestler wrote:

> > What does it mean that the "application layer has to be determine what
> > pages are registered"? The application does not know which of its
> pages
> > are currently in memory. It can only force these pages to stay in
> > memory if their are mlocked.
> > 
> 
> An application that advertises an RDMA accessible buffer
> to a remote peer *does* have to know that its pages *are*
> currently in memory.

Ok that would mean it needs to inform the VM of that issue by mlocking 
these pages.
 
> But the more fundamental issue is recognizing that applications
> that use direct interfaces need to know that buffers that they
> enable truly have committed resources. They need a way to
> ask for twenty *real* pages, not twenty pages of address
> space. And they need to do it in a way that allows memory
> to be rearranged or even migrated with them to a new host.

mlock will force the pages to stay in memory without requiring the OS to 
keep them where they are.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
