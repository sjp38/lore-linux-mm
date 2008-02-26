From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [ofa-general] Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps (f.e. for XPmem)
Date: Tue, 26 Feb 2008 19:52:41 +1100
References: <20080215064859.384203497@sgi.com> <200802261711.33213.nickpiggin@yahoo.com.au> <20080226072137.GD26611@minantech.com>
In-Reply-To: <20080226072137.GD26611@minantech.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802261952.42567.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Robin Holt <holt@sgi.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, general@lists.openfabrics.org, akpm@linux-foundation.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 26 February 2008 18:21, Gleb Natapov wrote:
> On Tue, Feb 26, 2008 at 05:11:32PM +1100, Nick Piggin wrote:
> > > You are missing one point here.  The MPI specifications that have
> > > been out there for decades do not require the process use a library
> > > for allocating the buffer.  I realize that is a horrible shortcoming,
> > > but that is the world we live in.  Even if we could change that spec,
> >
> > Can you change the spec?
>
> Not really. It will break all existing codes.

I meant as in eg. submit changes to MPI-3


> MPI-2 provides a call for 
> memory allocation (and it's beneficial to use this call for some
> interconnects), but many (most?) applications are still written for MPI-1
> and those that are written for MPI-2 mostly uses the old habit of
> allocating memory by malloc(), or even use stack or BSS memory for
> communication buffer purposes.

OK, so MPI-2 already has some way to do that... I'm not saying that we
can now completely dismiss the idea of using notifiers for this, but it
is just a good data point to know.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
