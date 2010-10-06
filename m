Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 40BB96B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 06:55:16 -0400 (EDT)
Date: Wed, 6 Oct 2010 12:55:04 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 07/12] Add async PF initialization to PV guest.
Message-ID: <20101006105504.GV11145@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-8-git-send-email-gleb@redhat.com>
 <20101005182554.GA1786@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101005182554.GA1786@amt.cnet>
Sender: owner-linux-mm@kvack.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 05, 2010 at 03:25:54PM -0300, Marcelo Tosatti wrote:
> On Mon, Oct 04, 2010 at 05:56:29PM +0200, Gleb Natapov wrote:
> > Enable async PF in a guest if async PF capability is discovered.
> > 
> > Signed-off-by: Gleb Natapov <gleb@redhat.com>
> > ---
> >  Documentation/kernel-parameters.txt |    3 +
> >  arch/x86/include/asm/kvm_para.h     |    5 ++
> >  arch/x86/kernel/kvm.c               |   92 +++++++++++++++++++++++++++++++++++
> >  3 files changed, 100 insertions(+), 0 deletions(-)
> > 
> 
> > +static int __cpuinit kvm_cpu_notify(struct notifier_block *self,
> > +				    unsigned long action, void *hcpu)
> > +{
> > +	int cpu = (unsigned long)hcpu;
> > +	switch (action) {
> > +	case CPU_ONLINE:
> > +	case CPU_DOWN_FAILED:
> > +	case CPU_ONLINE_FROZEN:
> > +		smp_call_function_single(cpu, kvm_guest_cpu_notify, NULL, 0);
> 
> wait parameter should probably be 1.
Why should we wait for it? FWIW I copied this from somewhere (May be
arch/x86/pci/amd_bus.c).

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
