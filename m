Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 977B06B0033
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 19:37:42 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 15so14590527pgc.16
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 16:37:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m37sor4103805pla.72.2017.11.06.16.37.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 16:37:41 -0800 (PST)
Date: Tue, 7 Nov 2017 11:37:29 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH for 4.15 10/14] cpu_opv: Wire up powerpc system call
Message-ID: <20171107113729.13369a30@roar.ozlabs.ibm.com>
In-Reply-To: <20171106205644.29386-11-mathieu.desnoyers@efficios.com>
References: <20171106092228.31098-1-mhocko@kernel.org>
	<1509992067.4140.1.camel@oracle.com>
	<20171106205644.29386-11-mathieu.desnoyers@efficios.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Boqun Feng <boqun.feng@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Dave Watson <davejwatson@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon,  6 Nov 2017 15:56:40 -0500
Mathieu Desnoyers <mathieu.desnoyers@efficios.com> wrote:

> diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
> index b1980fcd56d5..972a7d68c143 100644
> --- a/arch/powerpc/include/uapi/asm/unistd.h
> +++ b/arch/powerpc/include/uapi/asm/unistd.h
> @@ -396,5 +396,6 @@
>  #define __NR_kexec_file_load	382
>  #define __NR_statx		383
>  #define __NR_rseq		384
> +#define __NR_cpu_opv		385

Sorry for bike shedding, but could we invest a few more keystrokes to
make these names a bit more readable?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
