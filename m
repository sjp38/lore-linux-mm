Date: Thu, 14 Feb 2008 18:37:55 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77030E2456@nekter>
Message-ID: <Pine.LNX.4.64.0802141836070.4898@schroedinger.engr.sgi.com>
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
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Caitlin Bestler <Caitlin.Bestler@neterion.com>
Cc: linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2008, Caitlin Bestler wrote:

> So any solution that requires the upper layers to suspend operations
> for a brief bit will require explicit interaction with those layers.
> No RDMA layer can perform the sleight of hand tricks that you seem
> to want it to perform.

Looks like it has to be up there right.
 
> AT the RDMA layer the best you could get is very brief suspensions for 
> the purpose of *re-arranging* memory, not of reducing the amount of 
> registered memory. If you need to reduce the amount of registered memory 
> then you have to talk to the application. Discussions on making it 
> easier for the application to trim a memory region dynamically might be 
> in order, but you will not work around the fact that the application 
> layer needs to determine what pages are registered. And they would 
> really prefer just to be told how much memory they can have up front, 
> they can figure out how to deal with that amount of memory on their own.

What does it mean that the "application layer has to be determine what 
pages are registered"? The application does not know which of its pages 
are currently in memory. It can only force these pages to stay in memory 
if their are mlocked.
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
