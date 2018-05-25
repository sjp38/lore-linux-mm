Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8C946B0005
	for <linux-mm@kvack.org>; Fri, 25 May 2018 10:06:03 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id a5-v6so3110708plp.8
        for <linux-mm@kvack.org>; Fri, 25 May 2018 07:06:03 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0122.outbound.protection.outlook.com. [104.47.1.122])
        by mx.google.com with ESMTPS id b39-v6si23629847plb.456.2018.05.25.07.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 May 2018 07:05:56 -0700 (PDT)
Subject: Re: [PATCH] userfaultfd: prevent non-cooperative events vs
 mcopy_atomic races
References: <1527061324-19949-1-git-send-email-rppt@linux.vnet.ibm.com>
 <0e1ce040-1beb-fd96-683c-1b18eb635fd6@virtuozzo.com>
 <20180524115613.GA16908@rapoport-lnx>
 <e42a383f-491a-b42a-347c-effe4b86b982@virtuozzo.com>
 <20180524190639.GD16908@rapoport-lnx>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <30794a36-ea91-c941-f59e-6545816a2265@virtuozzo.com>
Date: Fri, 25 May 2018 17:05:42 +0300
MIME-Version: 1.0
In-Reply-To: <20180524190639.GD16908@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Andrei Vagin <avagin@virtuozzo.com>


>> But doesn't it race even with regular PF handling, not only the fork? How
>> do we handle this race?
> 
> With the regular #PF handing, the faulting thread patiently waits until
> page fault is resolved. With fork(), mremap() etc the thread that caused
> the event resumes once the uffd message is read by the monitor. That's
> surely way before monitor had chance to somehow process that message.

Ouch, yes. This is nasty :( So having no better solution in mind, let's
move forward with this.

Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>
