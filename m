Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id F25FD8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:25:31 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id x64so7134022ywc.6
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 20:25:31 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a201si3013998ywa.415.2019.01.10.20.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 20:25:31 -0800 (PST)
Subject: Re: [PATCH 3/3] bitops.h: set_mask_bits() to return old value
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
 <1547166387-19785-4-git-send-email-vgupta@synopsys.com>
From: Anthony Yznaga <anthony.yznaga@oracle.com>
Message-ID: <693b30a9-96dc-a5e6-9708-c215b90146b0@oracle.com>
Date: Thu, 10 Jan 2019 20:25:09 -0800
MIME-Version: 1.0
In-Reply-To: <1547166387-19785-4-git-send-email-vgupta@synopsys.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineet.gupta1@synopsys.com>, linux-kernel@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, peterz@infradead.org, Miklos Szeredi <mszeredi@redhat.com>, Ingo Molnar <mingo@kernel.org>, Jani Nikula <jani.nikula@intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>



On 1/10/19 4:26 PM, Vineet Gupta wrote:
> | > Also, set_mask_bits is used in fs quite a bit and we can possibly come up
> | > with a generic llsc based implementation (w/o the cmpxchg loop)
> |
> | May I also suggest changing the return value of set_mask_bits() to old.
> |
> | You can compute the new value given old, but you cannot compute the old
> | value given new, therefore old is the better return value. Also, no
> | current user seems to use the return value, so changing it is without
> | risk.
>
> Link: http://lkml.kernel.org/g/20150807110955.GH16853@twins.programming.kicks-ass.net
> Suggested-by: Peter Zijlstra <peterz@infradead.org>
> Cc: Miklos Szeredi <mszeredi@redhat.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Jani Nikula <jani.nikula@intel.com>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
>

Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>
