Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 72F876B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 04:36:44 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id m184so19629934iof.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:36:44 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id is4si3535684igb.43.2016.03.08.01.36.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 01:36:43 -0800 (PST)
Message-ID: <1457429794.31524.1.camel@ellerman.id.au>
Subject: Re: [PATCH 2/2] powerpc/mm: Enable page parallel initialisation
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 08 Mar 2016 20:36:34 +1100
In-Reply-To: <1457409354-10867-3-git-send-email-zhlcindy@gmail.com>
References: <1457409354-10867-1-git-send-email-zhlcindy@gmail.com>
	 <1457409354-10867-3-git-send-email-zhlcindy@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhang <zhlcindy@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

Hi Li,

On Tue, 2016-03-08 at 11:55 +0800, Li Zhang wrote:

> From: Li Zhang <zhlcindy@linux.vnet.ibm.com>
>
> Parallel initialisation has been enabled for X86, boot time is
> improved greatly. On Power8, it is improved greatly for small
> memory. Here is the result from my test on Power8 platform:
>
> For 4GB memory: 57% is improved, boot time as the following:
> with patch: 10s, without patch: 24.5s

This isn't worded quite right, and the numbers are a bit off.

old = 24.5
new = 10

So the improvement is 14.5 (seconds).

That means the improvement (14.5) as a percentage of the original boot time is:

 = 14.5 / 24.5 * 100
 = 59.183673469387756
 = 59%

So you would say:

  For 4GB of memory, boot time is improved by 59%, from 24.5s to 10s.

> For 50GB memory: 22% is improved, boot time as the following:
> with patch: 43.8s, without patch: 56.8s

  For 50GB memory, boot time is improved by 22%, from 56.8s to 43.8s.

> Acked-by: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>
> ---
>  * Add boot time details in change log.
>  * Please apply this patch after [PATCH 1/2] mm: meminit: initialise
>     more memory for inode/dentry hash tables in early boot, because
>    [PATCH 1/2] is to fix a bug which can be reproduced on Power.

Given that, I think it would be best if Andrew merged both of these patches.
Because this patch is pretty trivial, whereas the patch to mm/ is less so.

Is that OK Andrew?

For this one:

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
