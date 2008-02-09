Subject: Re: [ofa-general] Re: [patch 0/6] MMU Notifiers V6
References: <20080208220616.089936205@sgi.com>
	<20080208142315.7fe4b95e.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802081528070.4036@schroedinger.engr.sgi.com>
	<20080208233636.GG26564@sgi.com>
	<Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
	<20080208234302.GH26564@sgi.com>
	<20080208155641.2258ad2c.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802081603430.4543@schroedinger.engr.sgi.com>
	<adaprv70yyt.fsf@cisco.com>
	<Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com>
From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 08 Feb 2008 16:22:41 -0800
In-Reply-To: <Pine.LNX.4.64.0802081614030.5115@schroedinger.engr.sgi.com> (Christoph Lameter's message of "Fri, 8 Feb 2008 16:16:34 -0800 (PST)")
Message-ID: <adalk5v0yi6.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: andrea@qumranet.com, a.p.zijlstra@chello.nl, izike@qumranet.com, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Of course we can always destroy the memory region but that would break
the semantics that applications expect.  Basically an application can
register some chunk of its memory and get a key that it can pass to a
remote peer to let the remote peer operate on its memory via RDMA.
And that memory region/key is expected to stay valid until there is an
application-level operation to destroy it (or until the app crashes or
gets killed, etc).

 > We could also let the unmapping fail if the driver indicates that the 
 > mapping must stay.

That would of course work -- dumb adapters would just always fail,
which might be inefficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
