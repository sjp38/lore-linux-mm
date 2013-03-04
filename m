Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id AAF666B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 06:15:41 -0500 (EST)
Message-ID: <5134824D.9070008@synopsys.com>
Date: Mon, 4 Mar 2013 16:45:25 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/2] memblock: add assertion for zero allocation alignment
References: <CAE9FiQV20uj_kOViCOd4gdPFuAf28fEbjhGCrzNogQWx5T3+zg@mail.gmail.com> <1361479940-8078-1-git-send-email-vgupta@synopsys.com> <CAOS58YPUSmsj2OUNGH7-0709R7MrzWS1dMwCykL0tGsnpyG+ig@mail.gmail.com>
In-Reply-To: <CAOS58YPUSmsj2OUNGH7-0709R7MrzWS1dMwCykL0tGsnpyG+ig@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,

On Friday 22 February 2013 02:23 AM, Tejun Heo wrote:
> On Thu, Feb 21, 2013 at 12:52 PM, Vineet Gupta
> <Vineet.Gupta1@synopsys.com> wrote:
>> This came to light when calling memblock allocator from arc port (for
>> copying flattended DT). If a "0" alignment is passed, the allocator
>> round_up() call incorrectly rounds up the size to 0.
>>
>> round_up(num, alignto) => ((num - 1) | (alignto -1)) + 1
>>
>> While the obvious allocation failure causes kernel to panic, it is
>> better to warn the caller to fix the code.
>>
>> Tejun suggested that instead of BUG_ON(!align) - which might be
>> ineffective due to pending console init and such, it is better to
>> WARN_ON, and continue the boot with a reasonable default align.
>>
>> Caller passing @size need not be handled similarly as the subsequent
>> panic will indicate that anyhow.
>>
>> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Yinghai Lu <yinghai@kernel.org>
>> Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: linux-mm@kvack.org
>> Cc: linux-kernel@vger.kernel.org
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> 
> Thanks.
> 

I'm hoping this will be routed via the mm tree.

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
