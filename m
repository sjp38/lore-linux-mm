Subject: Demand paging for memory regions (was Re: MMU Notifiers V6)
References: <Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
	<20080208234302.GH26564@sgi.com>
	<20080208155641.2258ad2c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802081603430.4543@schroedinger.engr.sgi.com>
	<adaprv70yyt.fsf@cisco.com>
	<Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com>
	<adalk5v0yi6.fsf@cisco.com>
	<Pine.LNX.4.64.0802081634070.5298@schroedinger.engr.sgi.com>
	<20080209012446.GB7051@v2.random>
	<Pine.LNX.4.64.0802081725200.5445@schroedinger.engr.sgi.com>
	<20080209015659.GC7051@v2.random>
	<Pine.LNX.4.64.0802081813300.5602@schroedinger.engr.sgi.com>
	<20080209075556.63062452@bree.surriel.com>
	<Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com>
From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 11 Feb 2008 14:40:12 -0800
In-Reply-To: <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com> (Christoph Lameter's message of "Sat, 9 Feb 2008 13:46:34 -0800 (PST)")
Message-ID: <ada3arzxgkz.fsf_-_@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: general@lists.openfabrics.org
Cc: Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

[Adding general@lists.openfabrics.org to get the IB/RDMA people involved]

This thread has patches that add support for notifying drivers when a
process's memory map changes.  The hope is that this is useful for
letting RDMA devices handle registered memory without pinning the
underlying pages, by updating the RDMA device's translation tables
whenever the host kernel's tables change.

Is anyone interested in working on using this for drivers/infiniband?
I am interested in participating, but I don't think I have enough time
to do this by myself.

Also, at least naively it seems that this is only useful for hardware
that has support for this type of demand paging, and can handle
not-present pages, generating interrupts for page faults, etc.  I know
that Mellanox HCAs should have this support; are there any other
devices that can do this?

The beginning of this thread is at <http://lkml.org/lkml/2008/2/8/458>.

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
