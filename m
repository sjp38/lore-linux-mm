Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 5C1256B0006
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 15:53:39 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id j8so68614qah.13
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 12:53:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1361479940-8078-1-git-send-email-vgupta@synopsys.com>
References: <CAE9FiQV20uj_kOViCOd4gdPFuAf28fEbjhGCrzNogQWx5T3+zg@mail.gmail.com>
	<1361479940-8078-1-git-send-email-vgupta@synopsys.com>
Date: Thu, 21 Feb 2013 12:53:38 -0800
Message-ID: <CAOS58YPUSmsj2OUNGH7-0709R7MrzWS1dMwCykL0tGsnpyG+ig@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] memblock: add assertion for zero allocation alignment
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 21, 2013 at 12:52 PM, Vineet Gupta
<Vineet.Gupta1@synopsys.com> wrote:
> This came to light when calling memblock allocator from arc port (for
> copying flattended DT). If a "0" alignment is passed, the allocator
> round_up() call incorrectly rounds up the size to 0.
>
> round_up(num, alignto) => ((num - 1) | (alignto -1)) + 1
>
> While the obvious allocation failure causes kernel to panic, it is
> better to warn the caller to fix the code.
>
> Tejun suggested that instead of BUG_ON(!align) - which might be
> ineffective due to pending console init and such, it is better to
> WARN_ON, and continue the boot with a reasonable default align.
>
> Caller passing @size need not be handled similarly as the subsequent
> panic will indicate that anyhow.
>
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
