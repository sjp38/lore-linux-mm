Date: Fri, 25 Jan 2008 13:25:50 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/4] [RFC] MMU Notifiers V1
In-Reply-To: <1201295921.6815.150.camel@pasglop>
Message-ID: <Pine.LNX.4.64.0801251323420.19633@schroedinger.engr.sgi.com>
References: <20080125055606.102986685@sgi.com>  <20080125114229.GA7454@v2.random>
 <1201295921.6815.150.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jan 2008, Benjamin Herrenschmidt wrote:

> Also, wouldn't there be a problem with something trying to use that
> interface to keep in sync a secondary device MMU such as the DRM or
> other accelerators, which might need virtual address based
> invalidation ?

Yes just doing the rmap based solution would have required DRM etc to 
maintain their own rmaps. So it looks that we need to go with both 
variants. Note that secondary device MMUs that need to run code outside of 
atomic context may still need to create their own rmaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
