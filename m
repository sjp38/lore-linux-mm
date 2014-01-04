Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B94FB6B0031
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 21:57:45 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id lj1so16546821pab.29
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 18:57:45 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ng9si18422196pbc.16.2014.01.03.18.57.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 18:57:44 -0800 (PST)
Message-ID: <52C7789E.9090408@oracle.com>
Date: Fri, 03 Jan 2014 21:57:34 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
References: <52B1C143.8080301@oracle.com> <52B871B2.7040409@oracle.com> <52C508FA.9030009@oracle.com>
In-Reply-To: <52C508FA.9030009@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/02/2014 01:36 AM, Bob Liu wrote:
> I have no idea why this BUG_ON was triggered.
> And it looks like 'mm: kernel BUG at mm/huge_memory.c:1440!' have the
> same call trace with this one. Perhaps they were introduced by the same
> reason.
> Could you confirm whether those issues exist in v3.13-rc6?

Yes, this is reproducible in 3.13-rc6.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
