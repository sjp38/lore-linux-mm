Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7162E6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:28:05 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v109so9614654wrc.5
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 09:28:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 90sor2211936wrs.63.2017.09.25.09.28.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 09:28:04 -0700 (PDT)
MIME-Version: 1.0
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 25 Sep 2017 09:27:43 -0700
Message-ID: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
Subject: Re: [PATCH v3 00/20] Speculative page faults
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

On Mon, Sep 18, 2017 at 12:15 AM, Laurent Dufour
<ldufour@linux.vnet.ibm.com> wrote:
> Despite the unprovable lockdep warning raised by Sergey, I didn't get any
> feedback on this series.
>
> Is there a chance to get it moved upstream ?

what is the status ?
We're eagerly looking forward for this set to land,
since we have several use cases for tracing that
will build on top of this set as discussed at Plumbers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
