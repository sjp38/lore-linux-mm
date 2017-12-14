Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD5536B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 15:40:42 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n126so3018340wma.7
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 12:40:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z63si3613300wmz.126.2017.12.14.12.40.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 12:40:38 -0800 (PST)
Date: Thu, 14 Dec 2017 12:40:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3] mm/mprotect: Add a cond_resched() inside
 change_pmd_range()
Message-Id: <20171214124035.e77706f0a314f2082a2d1b7c@linux-foundation.org>
In-Reply-To: <20171214140551.5794-1-khandual@linux.vnet.ibm.com>
References: <20171214140551.5794-1-khandual@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

On Thu, 14 Dec 2017 19:35:51 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:

> While testing on a large CPU system, detected the following RCU
> stall many times over the span of the workload. This problem
> is solved by adding a cond_resched() in the change_pmd_range()
> function.
> 
> [  850.962530] INFO: rcu_sched detected stalls on CPUs/tasks:

That's a bit rude.  I think I'll add a cc:stable to this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
