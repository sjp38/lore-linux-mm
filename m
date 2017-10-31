Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA586B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 12:39:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id f66so19647725oib.1
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:39:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o55si1228795otd.163.2017.10.31.09.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 09:39:10 -0700 (PDT)
Date: Tue, 31 Oct 2017 17:39:07 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] pids: introduce find_get_task_by_vpid helper
Message-ID: <20171031163906.GA576@redhat.com>
References: <1509126753-3297-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509126753-3297-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On 10/27, Mike Rapoport wrote:
>
> There are several functions that do find_task_by_vpid() followed by
> get_task_struct(). We can use a helper function instead.
>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>
> v2: remove  futex_find_get_task() and ptrace_get_task_struct() as Oleg
> suggested

Acked-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
