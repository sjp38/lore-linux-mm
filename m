Date: Fri, 18 Jan 2008 13:08:40 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/1] x86: Fixup NR-CPUS patch for numa
Message-ID: <20080118120840.GE11044@elte.hu>
References: <20080116183438.506737000@sgi.com> <20080116183438.636758000@sgi.com> <20080117103000.5e97dcd2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080117103000.5e97dcd2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: travis@sgi.com, Andi Kleen <ak@suse.de>, Eric Dumazet <dada1@cosmosbay.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> wrote:

> > Also, the mem -> node hash lookup is fixed.
> > 
> > Based on 2.6.24-rc6-mm1 + change-NR_CPUS-V3 patchset
> 
> hm, I've been hiding from those patches.
> 
> Are they ready?

i'm carrying them in x86.git, and they are pretty robust, with one 
outstanding build failure.

( and i've asked Mike for a CONFIG_SMP_MAX debug option that selects the
  baddest high-end features we have with 1024 or 4096 CPUs, etc. - this 
  way allyesconfig bootups will show us any problems on that scale of 
  the spectrum. )

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
