Date: Fri, 8 Feb 2008 18:16:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [ofa-general] Re: [patch 0/6] MMU Notifiers V6
In-Reply-To: <20080209015659.GC7051@v2.random>
Message-ID: <Pine.LNX.4.64.0802081813300.5602@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
 <20080208234302.GH26564@sgi.com> <20080208155641.2258ad2c.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802081603430.4543@schroedinger.engr.sgi.com>
 <adaprv70yyt.fsf@cisco.com> <Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com>
 <adalk5v0yi6.fsf@cisco.com> <Pine.LNX.4.64.0802081634070.5298@schroedinger.engr.sgi.com>
 <20080209012446.GB7051@v2.random> <Pine.LNX.4.64.0802081725200.5445@schroedinger.engr.sgi.com>
 <20080209015659.GC7051@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Roland Dreier <rdreier@cisco.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, 9 Feb 2008, Andrea Arcangeli wrote:

> The VM shouldn't break if try_to_unmap doesn't actually make the page
> freeable for whatever reason. Permanent pins shouldn't happen anyway,

VM is livelocking if too many page are pinned that way right now. The 
higher the processors per node the higher the risk of livelock because 
more processors are in the process of cycling through pages that have an 
elevated refcount.

> so defining an ad-hoc API for that doesn't sound too appealing. Not
> sure if old hardware deserves those special lru-size-reduction
> optimizations but it's not my call (certainly swapoff/mlock would get
> higher priority in that lru-size-reduction area).

Rik has a patchset under development that addresses issues like this. The 
elevated refcount pin problem is not really relevant to the patchset we 
are discussing here.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
