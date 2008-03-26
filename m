Date: Wed, 26 Mar 2008 21:29:13 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: What if a TLB flush needed to sleep?
In-Reply-To: <Pine.LNX.4.64.0803261222090.31000@schroedinger.engr.sgi.com>
Message-ID: <alpine.LFD.1.00.0803262121440.3781@apollo.tec.linutronix.de>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com> <Pine.LNX.4.64.0803261222090.31000@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Mar 2008, Christoph Lameter wrote:

> On Tue, 25 Mar 2008, Luck, Tony wrote:
> 
> > 2) Is it feasible to rearrange the MM code so that we don't
> > hold any locks while doing a TLB flush?  Or should I implement
> > some sort of spin_only_semaphore?
> 
> The EMM notifier V2 patchset contains two patches that 
> convert the immap_lock and the anon_vma lock to semaphores.

Please use a mutex, not a semaphore. semaphores should only be used
when you need a counting sempahore.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
