Date: Thu, 14 Feb 2008 09:53:33 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080214155333.GA1029@sgi.com>
References: <adazlu5vlub.fsf@cisco.com> <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com> <47B45994.7010805@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47B45994.7010805@opengridcomputing.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: Felix Marti <felix@chelsio.com>, Roland Dreier <rdreier@cisco.com>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2008 at 09:09:08AM -0600, Steve Wise wrote:
> Note that for T3, this involves suspending _all_ rdma connections that are 
> in the same PD as the MR being remapped.  This is because the driver 
> doesn't know who the application advertised the rkey/stag to.  So without 

Is there a reason the driver can not track these.

> Point being, it will stop probably all connections that an application is 
> using (assuming the application uses a single PD).

It seems like the need to not stop all would be a compelling enough reason
to modify the driver to track which processes have received the rkey/stag.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
