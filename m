Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 258916B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 19:34:47 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k20so10633483wre.6
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 16:34:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u31si5873690wrc.285.2017.09.25.16.34.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 16:34:46 -0700 (PDT)
Date: Mon, 25 Sep 2017 16:34:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 00/20] Speculative page faults
Message-Id: <20170925163443.260d6092160ec704e2b04653@linux-foundation.org>
In-Reply-To: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
References: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

On Mon, 25 Sep 2017 09:27:43 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Mon, Sep 18, 2017 at 12:15 AM, Laurent Dufour
> <ldufour@linux.vnet.ibm.com> wrote:
> > Despite the unprovable lockdep warning raised by Sergey, I didn't get any
> > feedback on this series.
> >
> > Is there a chance to get it moved upstream ?
> 
> what is the status ?
> We're eagerly looking forward for this set to land,
> since we have several use cases for tracing that
> will build on top of this set as discussed at Plumbers.

There has been sadly little review and testing so far :(

I'll be taking a close look at it all over the next couple of weeks. 

One terribly important thing (especially for a patchset this large and
intrusive) is the rationale for merging it: the justification, usually
in the form of end-user benefit.

Laurent's [0/n] provides some nice-looking performance benefits for
workloads which are chosen to show performance benefits(!) but, alas,
no quantitative testing results for workloads which we may suspect will
be harmed by the changes(?).  Even things as simple as impact upon
single-threaded pagefault-intensive workloads and its effect upon
CONFIG_SMP=n .text size?

If you have additional usecases then please, spell them out for us in
full detail so we can better understand the benefits which this
patchset provides.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
