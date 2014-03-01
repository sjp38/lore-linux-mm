Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id DF7796B006E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 22:18:58 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id h3so3206083igd.5
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 19:18:58 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g14si11390565igt.23.2014.02.28.19.18.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 19:18:58 -0800 (PST)
Message-ID: <53115184.2080301@oracle.com>
Date: Fri, 28 Feb 2014 22:18:28 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: do_shared_fault: fix potential NULL pointer dereference
References: <1393507600-24752-1-git-send-email-bob.liu@oracle.com>	<20140227154808.cbe04fa80cb47e2e091daa31@linux-foundation.org>	<20140227235959.GA9424@node.dhcp.inet.fi>	<20140228090745.GE27965@twins.programming.kicks-ass.net>	<20140228135950.4a49ce89b5bff12c149b1f73@linux-foundation.org> <CAA_GA1dzMA+RS=TtM6ieJ7_DY5ruAbY9a4Ui9O7EYuvc-bSH_A@mail.gmail.com>
In-Reply-To: <CAA_GA1dzMA+RS=TtM6ieJ7_DY5ruAbY9a4Ui9O7EYuvc-bSH_A@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Bob Liu <bob.liu@oracle.com>, Linux-MM <linux-mm@kvack.org>

On 02/28/2014 10:14 PM, Bob Liu wrote:
> BTW: Sasha, could you please have a test with this patch?

Yup, it's running ever since you sent the patch.

I've seen the issue occur only once, so I'd like to leave it for at least over the weekend before 
confirming it's gone.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
