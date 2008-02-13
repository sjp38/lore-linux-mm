Date: Tue, 12 Feb 2008 21:26:00 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080213042600.GA32449@obsidianresearch.com>
References: <20080209075556.63062452@bree.surriel.com> <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com> <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com> <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com> <20080213032533.GC32047@obsidianresearch.com> <47B26A6A.4000209@myri.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47B26A6A.4000209@myri.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Patrick Geoffray <patrick@myri.com>
Cc: Christoph Lameter <clameter@sgi.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

[mangled CC list trimmed]
On Tue, Feb 12, 2008 at 10:56:26PM -0500, Patrick Geoffray wrote:

> Jason Gunthorpe wrote:
>> I don't know much about Quadrics, but I would be hesitant to lump it
>> in too much with these RDMA semantics. Christian's comments sound like
>> they operate closer to what you described and that is why the have an
>> existing patch set. I don't know :)
>
> The Quadrics folks have been doing RDMA for 10 years, there is a reason why 
> they maintained a patch.

This wasn't ment as a slight against Quadrics, only to point out that
the specific wire protcols used by IB and iwarp are what cause this
limitation, it would be easy to imagine that Quadrics has some
additional twist that can make this easier..

>> What it boils down to is that to implement true removal of pages in a
>> general way the kernel and HCA must either drop packets or stall
>> incoming packets, both are big performance problems - and I can't see
>> many users wanting this. Enterprise style people using SCSI, NFS, etc
>> already have short pin periods and HPC MPI users probably won't care
>> about the VM issues enough to warrent the performance overhead.
>
> This is not true, HPC people do care about the VM issues a lot. Memory
> registration (pinning and translating) is usually too expensive to

I ment that HPC users are unlikely to want to swap active RDMA pages
if this causes a performance cost on normal operations. None of my
comments are ment to imply that lazy de-registration or page migration
are not good things.

Regards,
Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
