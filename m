Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4A886B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 23:49:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m18so10513200pgu.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 20:49:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e6si223919pff.205.2018.03.26.20.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 20:49:54 -0700 (PDT)
Date: Mon, 26 Mar 2018 20:49:36 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v9 21/24] perf tools: Add support for the SPF perf event
Message-ID: <20180327034936.GO13724@tassilo.jf.intel.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-22-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803261443560.255554@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803261443560.255554@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Mon, Mar 26, 2018 at 02:44:48PM -0700, David Rientjes wrote:
> On Tue, 13 Mar 2018, Laurent Dufour wrote:
> 
> > Add support for the new speculative faults event.
> > 
> > Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Aside: should there be a new spec_flt field for struct task_struct that 
> complements maj_flt and min_flt and be exported through /proc/pid/stat?

No. task_struct is already too bloated. If you need per process tracking 
you can always get it through trace points.

-Andi
