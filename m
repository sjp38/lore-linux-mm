Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id B2ECA6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 07:09:22 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id n16so8971376oag.5
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 04:09:22 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id ns8si9401660obc.22.2014.02.11.04.09.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 04:09:21 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 11 Feb 2014 05:09:21 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id D2D6919D8036
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:09:17 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1BC9Icm10420730
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:09:18 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s1BCCdm0005162
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:12:39 -0700
Date: Tue, 11 Feb 2014 04:09:16 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Memory allocator semantics
Message-ID: <20140211120915.GP4250@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20140102203320.GA27615@linux.vnet.ibm.com>
 <52F60699.8010204@iki.fi>
 <20140209020004.GY4250@linux.vnet.ibm.com>
 <CAOJsxLHs890eypzfnNj4ff1zqy_=bC8FA7B0YYbcZQF_c_wSog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLHs890eypzfnNj4ff1zqy_=bC8FA7B0YYbcZQF_c_wSog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

On Tue, Feb 11, 2014 at 10:50:24AM +0200, Pekka Enberg wrote:
> Hi Paul,
> 
> On Sun, Feb 9, 2014 at 4:00 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > From what I can see, (A) works by accident, but is kind of useless because
> > you allocate and free the memory without touching it.  (B) and (C) are the
> > lightest touches I could imagine, and as you say, both are bad.  So I
> > believe that it is reasonable to prohibit (A).
> >
> > Or is there some use for (A) that I am missing?
> 
> So again, there's nothing in (A) that the memory allocator is
> concerned about.  kmalloc() makes no guarantees whatsoever about the
> visibility of "r1" across CPUs.  If you're saying that there's an
> implicit barrier between kmalloc() and kfree(), that's an unintended
> side-effect, not a design decision AFAICT.

Thank you.  That was what I suspected, and I believe that it is a
completely reasonable response to (A).

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
