Date: Fri, 15 Feb 2008 14:50:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77030E2657@nekter>
Message-ID: <Pine.LNX.4.64.0802151445100.16270@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
 <ada3arzxgkz.fsf_-_@cisco.com>  <47B2174E.5000708@opengridcomputing.com>
 <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>
 <adazlu5vlub.fsf@cisco.com>  <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>
  <47B45994.7010805@opengridcomputing.com>  <Pine.LNX.4.64.0802141137140.500@schroedinger.engr.sgi.com>
  <469958e00802141217i3a3d16a1k1232d69b8ba54471@mail.gmail.com>
 <Pine.LNX.4.64.0802141219110.1041@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0802141445570.3298@schroedinger.engr.sgi.com>
 <78C9135A3D2ECE4B8162EBDCE82CAD77030E2456@nekter>
 <Pine.LNX.4.64.0802141836070.4898@schroedinger.engr.sgi.com>
 <78C9135A3D2ECE4B8162EBDCE82CAD77030E25BA@nekter>
 <Pine.LNX.4.64.0802151044310.12890@schroedinger.engr.sgi.com>
 <78C9135A3D2ECE4B8162EBDCE82CAD77030E25F1@nekter>
 <Pine.LNX.4.64.0802151158560.14517@schroedinger.engr.sgi.com>
 <78C9135A3D2ECE4B8162EBDCE82CAD77030E2657@nekter>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Caitlin Bestler <Caitlin.Bestler@neterion.com>
Cc: linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Fri, 15 Feb 2008, Caitlin Bestler wrote:

> There isn't much point in the RDMA layer subscribing to mmu
> notifications
> if the specific RDMA device will not be able to react appropriately when
> the notification occurs. I don't see how you get around needing to know
> which devices are capable of supporting page migration (via
> suspend/resume
> or other mechanisms) and which can only respond to a page migration by
> aborting connections.

You either register callbacks if the device can react properly or you 
dont. If you dont then the device will continue to have the problem with 
page pinning etc until someone comes around and implements the 
mmu callbacks to fix these issues.

I have doubts regarding the claim that some devices just cannot be made to 
suspend and resume appropriately. They obviously can be shutdown and so 
its a matter of sequencing the things the right way. I.e. stop the app 
wait for a quiet period then release resources etc.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
