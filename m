Date: Fri, 8 Feb 2008 15:56:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/6] MMU Notifiers V6
Message-Id: <20080208155641.2258ad2c.akpm@linux-foundation.org>
In-Reply-To: <20080208234302.GH26564@sgi.com>
References: <20080208220616.089936205@sgi.com>
	<20080208142315.7fe4b95e.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802081528070.4036@schroedinger.engr.sgi.com>
	<20080208233636.GG26564@sgi.com>
	<Pine.LNX.4.64.0802081540180.4291@schroedinger.engr.sgi.com>
	<20080208234302.GH26564@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, andrea@qumranet.com, avi@qumranet.com, izike@qumranet.com, kvm-devel@lists.sourceforge.net, a.p.zijlstra@chello.nl, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Feb 2008 17:43:02 -0600 Robin Holt <holt@sgi.com> wrote:

> On Fri, Feb 08, 2008 at 03:41:24PM -0800, Christoph Lameter wrote:
> > On Fri, 8 Feb 2008, Robin Holt wrote:
> > 
> > > > > What about ib_umem_get()?
> > 
> > Correct.
> > 
> > You missed the turn of the conversation to how ib_umem_get() works. 
> > Currently it seems to pin the same way that the SLES10 XPmem works.
> 
> Ah.  I took Andrew's question as more of a probe about whether we had
> worked with the IB folks to ensure this fits the ib_umem_get needs
> as well.
> 

You took it correctly, and I didn't understand the answer ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
