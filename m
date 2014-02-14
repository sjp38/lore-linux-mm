Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 69FC06B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 12:30:56 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id w8so18922707qac.0
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 09:30:56 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id j4si4321822qao.24.2014.02.14.09.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 09:30:55 -0800 (PST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 14 Feb 2014 10:30:54 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id ED5243E4003F
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:30:51 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1EHUOqN3080582
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 18:30:24 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s1EHYEhw011354
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:34:14 -0700
Date: Fri, 14 Feb 2014 09:30:39 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Memory allocator semantics
Message-ID: <20140214173038.GR4250@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140102203320.GA27615@linux.vnet.ibm.com>
 <52F60699.8010204@iki.fi>
 <20140209020004.GY4250@linux.vnet.ibm.com>
 <CAOJsxLHs890eypzfnNj4ff1zqy_=bC8FA7B0YYbcZQF_c_wSog@mail.gmail.com>
 <alpine.DEB.2.10.1402111242380.28186@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402111242380.28186@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>

On Tue, Feb 11, 2014 at 12:43:35PM -0600, Christoph Lameter wrote:
> On Tue, 11 Feb 2014, Pekka Enberg wrote:
> 
> > So again, there's nothing in (A) that the memory allocator is
> > concerned about.  kmalloc() makes no guarantees whatsoever about the
> > visibility of "r1" across CPUs.  If you're saying that there's an
> > implicit barrier between kmalloc() and kfree(), that's an unintended
> > side-effect, not a design decision AFAICT.
> 
> I am not sure that this side effect necessarily happens. The SLUB fastpath
> does not disable interrupts and only uses a cmpxchg without lock
> semantics.

That tells me what I need to know.  Users should definitely not try a
"drive-by kfree()" of something that was concurrently allocated.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
