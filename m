Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1DB566B0032
	for <linux-mm@kvack.org>; Sun, 25 Jan 2015 09:44:35 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so6828793pad.7
        for <linux-mm@kvack.org>; Sun, 25 Jan 2015 06:44:34 -0800 (PST)
Received: from out11.mail.aliyun.com (out11.mail.aliyun.com. [205.204.117.240])
        by mx.google.com with ESMTP id bb9si7488202pbd.46.2015.01.25.06.44.32
        for <linux-mm@kvack.org>;
        Sun, 25 Jan 2015 06:44:34 -0800 (PST)
Message-ID: <54C500F0.3070903@aliyun.com>
Date: Sun, 25 Jan 2015 22:42:56 +0800
From: Zhang Yanfei <zhangyanfei.linux@aliyun.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: incorporate read-only pages into transparent huge
 pages
References: <1421999256-3881-1-git-send-email-ebru.akagunduz@gmail.com> <20150123191816.GN11755@redhat.com> <54C4B680.3010304@suse.cz>
In-Reply-To: <54C4B680.3010304@suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, riel@redhat.com

Hello

a?? 2015/1/25 17:25, Vlastimil Babka a??e??:
> On 23.1.2015 20:18, Andrea Arcangeli wrote:
>>> >+        if (!pte_write(pteval)) {
>>> >+            if (++ro > khugepaged_max_ptes_none)
>>> >+                goto out_unmap;
>>> >+        }
>> It's true this is maxed out at 511, so there must be at least one
>> writable and not none pte (as results of the two "ro" and "none"
>> counters checks).
> 
> Hm, but if we consider ro and pte_none separately, both can be lower
> than 512, but the sum of the two can be 512, so we can actually be in
> read-only VMA?

Yes, I also think so.

So is it necessary to add a at-least-one-writable-pte check just like the existing
at-least-one-page-referenced check?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
