Received: by qb-out-0506.google.com with SMTP id e21so11297575qba.0
        for <linux-mm@kvack.org>; Thu, 14 Feb 2008 14:43:55 -0800 (PST)
Message-ID: <469958e00802141443g33448abcs3efa6d6c4aec2b56@mail.gmail.com>
Date: Thu, 14 Feb 2008 14:43:54 -0800
From: "Caitlin Bestler" <caitlin.bestler@neterion.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <Pine.LNX.4.64.0802141219110.1041@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
	 <ada3arzxgkz.fsf_-_@cisco.com>
	 <47B2174E.5000708@opengridcomputing.com>
	 <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>
	 <adazlu5vlub.fsf@cisco.com>
	 <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>
	 <47B45994.7010805@opengridcomputing.com>
	 <Pine.LNX.4.64.0802141137140.500@schroedinger.engr.sgi.com>
	 <469958e00802141217i3a3d16a1k1232d69b8ba54471@mail.gmail.com>
	 <Pine.LNX.4.64.0802141219110.1041@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2008 at 12:20 PM, Christoph Lameter <clameter@sgi.com> wrote:
> On Thu, 14 Feb 2008, Caitlin Bestler wrote:
>
>  > So suspend/resume to re-arrange pages is one thing. Suspend/resume to cover
>  > swapping out pages so they can be reallocated is an exercise in futility. By the
>  > time you resume the connections will be broken or at the minimum damaged.
>
>  The connections would then have to be torn down before swap out and would
>  have to be reestablished after the pages have been brought back from swap.
>
>
I have no problem with that, as long as the application layer is responsible for
tearing down and re-establishing the connections. The RDMA/transport layers
are incapable of tearing down and re-establishing a connection transparently
because connections need to be approved above the RDMA layer.

Further the teardown will have visible artificats that the application
must deal with,
such as flushed Recv WQEs.

This is still, the RDMA device will do X and will not worry about Y. The reasons
for not worrying about Y could be that the suspend will be very short, or that
other mechanisms have taken care  of all the Ys independently.

For example, an HPC cluster that suspended the *entire* cluster would not
have to worry about dropped packets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
