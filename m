From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86_64 Question: Are concurrent IPI requests safe?
Date: Wed, 11 May 2016 16:33:44 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1605111631430.3540@nanos>
References: <201605061958.HHG48967.JVFtSLFQOFOOMH@I-love.SAKURA.ne.jp> <201605092354.AHF82313.FtQFOMVOFJLOSH@I-love.SAKURA.ne.jp> <alpine.DEB.2.11.1605091853130.3540@nanos> <201605112219.HEB64012.FLQOFMJOVOtFHS@I-love.SAKURA.ne.jp>
 <20160511133928.GF3192@twins.programming.kicks-ass.net> <201605112309.AGJ18252.tOFMFQOJFLSOVH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201605112309.AGJ18252.tOFMFQOJFLSOVH@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Wed, 11 May 2016, Tetsuo Handa wrote:
> Peter Zijlstra wrote:
> > On Wed, May 11, 2016 at 10:19:16PM +0900, Tetsuo Handa wrote:
> > > [  180.434659] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> > 
> > can you reproduce on real hardware?
> > 
> Unfortunately, I don't have a real hardware to run development kernels.
> 
> My Linux environment is limited to 4 CPUs / 1024MB or 2048MB RAM running
> as a VMware guest on Windows. Can somebody try KVM environment with
> 4 CPUs / 1024MB or 2048MB RAM whith partition only plain /dev/sda1
> formatted as XFS?

Can you trigger a back trace on all cpus when the watchdog triggers?

Thanks,

	tglx


 
