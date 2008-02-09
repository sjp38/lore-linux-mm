Date: Sat, 9 Feb 2008 02:24:46 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [ofa-general] Re: [patch 0/6] MMU Notifiers V6
Message-ID: <20080209012446.GB7051@v2.random>
References: <Pine.LNX.4.64.0802081528070.4036@schroedinger.engr.sgi.com> <20080208233636.GG26564@sgi.com> <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com> <20080208234302.GH26564@sgi.com> <20080208155641.2258ad2c.akpm@linux-foundation.org> <Pine.LNX.4.64.0802081603430.4543@schroedinger.engr.sgi.com> <adaprv70yyt.fsf@cisco.com> <Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com> <adalk5v0yi6.fsf@cisco.com> <Pine.LNX.4.64.0802081634070.5298@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802081634070.5298@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Roland Dreier <rdreier@cisco.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2008 at 04:36:16PM -0800, Christoph Lameter wrote:
> On Fri, 8 Feb 2008, Roland Dreier wrote:
> 
> > That would of course work -- dumb adapters would just always fail,
> > which might be inefficient.
> 
> Hmmmm.. that means we need something that actually pins pages for good so 
> that the VM can avoid reclaiming it and so that page migration can avoid 
> trying to migrate them. Something like yet another page flag.

What's wrong with pinning with the page count like now? Dumb adapters
would simply not register themself in the mmu notifier list no?

> 
> Ccing Rik.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
