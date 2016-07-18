Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07B406B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 11:37:59 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a123so398776536qkd.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 08:37:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q51si10809868qtc.117.2016.07.18.08.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 08:37:58 -0700 (PDT)
Date: Mon, 18 Jul 2016 17:38:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/14] resource limits: track highwater mark of locked
	memory
Message-ID: <20160718153802.GA31174@redhat.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com> <1468578983-28229-10-git-send-email-toiwoton@gmail.com> <20160715151408.GA32317@redhat.com> <5c43bc33-6625-ceb7-e96e-adf7df5b642c@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5c43bc33-6625-ceb7-e96e-adf7df5b642c@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Topi Miettinen <toiwoton@gmail.com>
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alexander Graf <agraf@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On 07/15, Topi Miettinen wrote:
>
> On 07/15/16 15:14, Oleg Nesterov wrote:
> >
> > Btw this is not right. The same for the previous patch which tracks
> > RLIMIT_STACK. The "current" task can debugger/etc.
>
> acct_stack_growth() is called from expand_upwards() and
> expand_downwards(). They call security_mmap_addr() and the various LSM
> implementations also use current task in the checks. Are these also not
> right?

Just suppose that the stack grows because you read/write to /proc/pid/mem.

> > Yes, yes, this just reminds that the whole rlimit logic in this path
> > is broken but still...
>
> I'd be happy to fix the logic with a separate prerequisite patch and
> then use the right logic for this patch, but I'm not sure I know how.
> Could you elaborate a bit?

If only I Knew how to fix this ;) I mean, if only I could suggest a
simple fix. Because IMHO we do not really care, rlimts are obsolete.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
