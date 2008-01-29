Date: Tue, 29 Jan 2008 11:49:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
In-Reply-To: <20080129135914.GF7233@v2.random>
Message-ID: <Pine.LNX.4.64.0801291148080.24807@schroedinger.engr.sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.609249585@sgi.com>
 <20080129135914.GF7233@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008, Andrea Arcangeli wrote:

> > +	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
> >  };
> 
> Not sure why you prefer to waste ram when MMU_NOTIFIER=n, this is a
> regression (a minor one though).

Andrew does not like #ifdefs and it makes it possible to verify calling 
conventions if !CONFIG_MMU_NOTIFIER.

> It's out of my reach how can you be ok with lock=1. You said you have
> to block, if you can deal with lock=1 once, why can't you deal with
> lock=1 _always_?

Not sure yet. We may have to do more in that area. Need to have feedback 
from Robin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
