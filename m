Date: Tue, 6 May 2008 11:56:13 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] fix SMP data race in pagetable setup vs walking
Message-ID: <20080506095613.GG10141@wotan.suse.de>
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <20080506.000803.80742226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080506.000803.80742226.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, hugh@veritas.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 12:08:03AM -0700, David Miller wrote:
> From: Nick Piggin <npiggin@suse.de>
> Date: Mon, 5 May 2008 14:12:40 +0200
> 
> > I only converted x86 and powerpc. I think comments in x86 are good because
> > that is more or less the reference implementation and is where many VM
> > developers would look to understand mm/ code. Commenting all page table
> > walking in all other architectures is kind of beyond my skill or patience,
> > and maintainers might consider this weird "alpha thingy" is below them ;)
> > But they are quite free to add smp_read_barrier_depends to their own code.
> > 
> > Still would like more acks on this before it is applied.
> 
> I've read this over a few times, I think it's OK:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks a lot for that (and the others who reviewed). Gives me more
confidence.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
