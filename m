Date: Wed, 16 Oct 2002 20:59:08 +0200
From: Henrik =?iso-8859-1?Q?St=F8rner?= <henrik@hswn.dk>
Subject: Re: 2.5.42-mm2 hangs system
Message-ID: <20021016185908.GA863@hswn.dk>
References: <20021013160451.GA25494@hswn.dk> <3DA9CA28.155BA5CB@digeo.com> <20021013223332.GA870@hswn.dk> <20021016183907.B29405@in.ibm.com> <20021016154943.GA13695@hswn.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20021016154943.GA13695@hswn.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Maneesh Soni <maneesh@in.ibm.com>
Cc: linux-mm@kvack.org, akpm@digeo.com, Dipankar Sarma <dipankar@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Maneesh,

On Wed, Oct 16, 2002 at 05:49:43PM +0200, Henrik Storner wrote:
> On Wed, Oct 16, 2002 at 06:39:07PM +0530, Maneesh Soni wrote:
> > As the hang looks like a loop in d_lookup can you  try
> > recreating it *without* dcache_rcu.patch. You can backout this patch
> > 
> > http://www.zipworld.com.au/~akpm/linux/patches/2.5/2.5.42/2.5.42-mm2/broken-out/dcache_rcu.patch
> > 
> I've got some time tonight, so I will try un-doing the patch you
> mention and see if that changes anything.

well you hit the nail right on the head there.

I've just been running the 2.5.42-mm2 kernel except for the dcache_rcu
patch for a full hour, and I was unable to reproduce the hangs that I
saw with the full -mm2 patch installed. Did two full kernel builds
while reading some mail and doing other stuff - no problems what so
ever.

Just to be sure, I re-applied the dcache_rcu patch, rebuilt the
kernel, booted with the kernel containing dcache_rcu patch,
and the system died within a few minutes.

So it is definitely something in the dcache_rcu patch that does it.

-- 
Henrik Storner <henrik@hswn.dk> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
