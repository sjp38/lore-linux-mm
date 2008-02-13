Message-ID: <47B2765A.2070901@myri.com>
Date: Tue, 12 Feb 2008 23:47:22 -0500
From: Patrick Geoffray <patrick@myri.com>
MIME-Version: 1.0
Subject: Re: [ofa-general] Re: Demand paging for memory regions
References: <20080209075556.63062452@bree.surriel.com> <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com> <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com> <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com> <20080213032533.GC32047@obsidianresearch.com> <47B26A6A.4000209@myri.com> <20080213042600.GA32449@obsidianresearch.com>
In-Reply-To: <20080213042600.GA32449@obsidianresearch.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Christoph Lameter <clameter@sgi.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

Jason Gunthorpe wrote:
> [mangled CC list trimmed]
Thanks, noticed that afterwards.

> This wasn't ment as a slight against Quadrics, only to point out that
> the specific wire protcols used by IB and iwarp are what cause this
> limitation, it would be easy to imagine that Quadrics has some
> additional twist that can make this easier..

The wire protocols are similar, nothing fancy. The specificity of 
Quadrics (and many others) is that they can change the behavior of the 
NIC in firmware, so they adapt to what the OS offers. They had the VM 
notifier support in Tru64 back in the days, they just ported the 
functionality to Linux.

> I ment that HPC users are unlikely to want to swap active RDMA pages
> if this causes a performance cost on normal operations. None of my

Swapping to disk is not a normal operations in HPC, it's going to be 
slow anyway. The main problem for HPC users is not swapping, it's that 
they do not know when a registered page is released to the OS through 
free(), sbrk() or munmap(). Like swapping, they don't expect that it 
will happen often, but they have to handle it gracefully.

Patrick
-- 
Patrick Geoffray
Myricom, Inc.
http://www.myri.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
