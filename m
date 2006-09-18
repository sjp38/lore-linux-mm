Date: Mon, 18 Sep 2006 10:49:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060918093434.e66b8887.pj@sgi.com>
Message-ID: <Pine.LNX.4.63.0609181042390.30784@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
 <20060917041707.28171868.pj@sgi.com> <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
 <20060917060358.ac16babf.pj@sgi.com> <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
 <20060917152723.5bb69b82.pj@sgi.com> <Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
 <20060917192010.cc360ece.pj@sgi.com> <20060918093434.e66b8887.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Sep 2006, Paul Jackson wrote:

> For now, it could be that we can't handle hybrid systems, and that fake
> numa systems simply have a distance table of all 10's, driven by the
> kernel boot command "numa=fake=N".  But that apparatus will have to be
> extended at some point, to support hybrid fake and real NUMA combined.
> And this will have to mature from being an arch=x86_64 only thing to
> being generically available.  And it will have to become a mechanism
> that can be applied on a running system, creating (and removing) fake
> nodes on the fly, without a reboot, so long as the required physical
> memory is free and available.
> 

Magnus Damm wrote a series of patches that divided real NUMA nodes into 
several smaller emulated nodes (real nodes - 1) for the x86_64.  They are 
from 2.6.14-mm1:

http://marc.theaimsgroup.com/?l=linux-mm&m=113161386520342&w=2

As already said, the only flag that exists to determine whether 
CONFIG_NUMA_EMU is enabled and numa=fake is being used (and used 
correctly) is the numa_fake int in arch/x86_64/mm/numa.c.  Any abstraction 
of this to generic kernel code should probably follow in the footsteps of 
Magnus' other patch series which moved must of NUMA emulation to generic 
architectures.  He used it primarily for implementing numa=fake on i386:

http://marc.theaimsgroup.com/?l=linux-mm&m=112806587501884&w=2

At the time it was suggested to emulate an SMP NUMA system where each 
node doesn't have all of its CPU's online.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
