Date: Fri, 8 Feb 2008 17:27:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [ofa-general] Re: [patch 0/6] MMU Notifiers V6
In-Reply-To: <20080209012446.GB7051@v2.random>
Message-ID: <Pine.LNX.4.64.0802081725200.5445@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802081528070.4036@schroedinger.engr.sgi.com>
 <20080208233636.GG26564@sgi.com> <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
 <20080208234302.GH26564@sgi.com> <20080208155641.2258ad2c.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802081603430.4543@schroedinger.engr.sgi.com>
 <adaprv70yyt.fsf@cisco.com> <Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com>
 <adalk5v0yi6.fsf@cisco.com> <Pine.LNX.4.64.0802081634070.5298@schroedinger.engr.sgi.com>
 <20080209012446.GB7051@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Roland Dreier <rdreier@cisco.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, 9 Feb 2008, Andrea Arcangeli wrote:

> > Hmmmm.. that means we need something that actually pins pages for good so 
> > that the VM can avoid reclaiming it and so that page migration can avoid 
> > trying to migrate them. Something like yet another page flag.
> 
> What's wrong with pinning with the page count like now? Dumb adapters
> would simply not register themself in the mmu notifier list no?

Pages will still be on the LRU and cycle through rmap again and again. 
If page migration is used on those pages then the code may make repeated 
attempt to migrate the page thinking that the page count must at some 
point drop.

I do not think that the page count was intended to be used to pin pages 
permanently. If we had a marker on such pages then we could take them off 
the LRU and not try to migrate them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
