Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF716B0253
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 16:32:53 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n7so4586039wrb.0
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 13:32:53 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j193si1816649wmb.4.2018.03.30.13.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 30 Mar 2018 13:32:51 -0700 (PDT)
Date: Fri, 30 Mar 2018 22:32:44 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 00/11] Use global pages with PTI
In-Reply-To: <3cdc23a2-99eb-6f93-6934-f7757fa30a3e@linux.intel.com>
Message-ID: <alpine.DEB.2.21.1803302230560.1479@nanos.tec.linutronix.de>
References: <20180323174447.55F35636@viggo.jf.intel.com> <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com> <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com> <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
 <c0e7ca0b-dcb5-66e2-9df6-f53e4eb22781@linux.intel.com> <alpine.DEB.2.21.1803271949250.1618@nanos.tec.linutronix.de> <20180327200719.lvdomez6hszpmo4s@gmail.com> <0d6ea030-ec3b-d649-bad7-89ff54094e25@linux.intel.com> <20180330120920.btobga44wqytlkoe@gmail.com>
 <20180330121725.zcklh36ulg7crydw@gmail.com> <3cdc23a2-99eb-6f93-6934-f7757fa30a3e@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?ISO-8859-15?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On Fri, 30 Mar 2018, Dave Hansen wrote:

> On 03/30/2018 05:17 AM, Ingo Molnar wrote:
> > BTW., the expectation on !PCID Intel hardware would be for global pages to help 
> > even more than the 0.6% and 1.7% you measured on PCID hardware: PCID already 
> > _reduces_ the cost of TLB flushes - so if there's not even PCID then global pages 
> > should help even more.
> > 
> > In theory at least. Would still be nice to measure it.
> 
> I did the lseek test on a modern, non-PCID system:
> 
> No Global pages (baseline): 6077741 lseeks/sec
> 94 Global pages (this set): 8433111 lseeks/sec
> 			   +2355370 lseeks/sec (+38.8%)

That's all kernel text, right? What's the result for the case where global
is only set for all user/kernel shared pages?

Thanks,

	tglx
