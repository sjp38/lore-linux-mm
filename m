Date: Tue, 26 Feb 2008 18:52:00 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [ofa-general] Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps (f.e. for XPmem)
In-Reply-To: <20080226093809.GF26611@minantech.com>
References: <200802261952.42567.nickpiggin@yahoo.com.au> <20080226093809.GF26611@minantech.com>
Message-Id: <20080226184914.FF3A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, general@lists.openfabrics.org, akpm@linux-foundation.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

> > > > Can you change the spec?
> > >
> > > Not really. It will break all existing codes.
> > 
> > I meant as in eg. submit changes to MPI-3
>
> MPI spec tries to be backward compatible. And MPI-2 spec is 10 years
> old, but MPI-1 is still in a wider use. HPC is moving fast in terms of HW
> technology, but slow in terms of SW. Fortran is still hot there :)

Agreed.
many many people dislike incompatible specification change.

We should accept real world spec.


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
