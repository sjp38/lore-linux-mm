Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 64B736B0256
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 02:45:07 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id b14so413537861wmb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 23:45:07 -0800 (PST)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id hw8si7691237wjb.80.2016.01.13.23.45.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jan 2016 23:45:06 -0800 (PST)
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Thu, 14 Jan 2016 07:45:05 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id D16E6219004D
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 07:44:51 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0E7j3VO63176822
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 07:45:03 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0E7j26q013147
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 02:45:02 -0500
Date: Thu, 14 Jan 2016 08:45:00 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH v5 5/7] s390: mm/gup: add gup trace points
Message-ID: <20160114074500.GA4073@osiris>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
 <1449696151-4195-6-git-send-email-yang.shi@linaro.org>
 <56969389.9060703@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56969389.9060703@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org

On Wed, Jan 13, 2016 at 10:12:25AM -0800, Shi, Yang wrote:
> Hi folks,
> 
> Any comment for this one? The tracing part review has been done.
> 
> Thanks,
> Yang

If the rest of this series has been acked by the appropriate maintainers
please feel free to add an

Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

for this specific patch.

> 
> On 12/9/2015 1:22 PM, Yang Shi wrote:
> >Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> >Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> >Cc: linux-s390@vger.kernel.org
> >Signed-off-by: Yang Shi <yang.shi@linaro.org>
> >---
> >  arch/s390/mm/gup.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> >
> >diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
> >index 12bbf0e..a1d5db7 100644
> >--- a/arch/s390/mm/gup.c
> >+++ b/arch/s390/mm/gup.c
> >@@ -12,6 +12,8 @@
> >  #include <linux/rwsem.h>
> >  #include <asm/pgtable.h>
> >
> >+#include <trace/events/gup.h>
> >+
> >  /*
> >   * The performance critical leaf functions are made noinline otherwise gcc
> >   * inlines everything into a single function which results in too much
> >@@ -188,6 +190,9 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >  	end = start + len;
> >  	if ((end <= start) || (end > TASK_SIZE))
> >  		return 0;
> >+
> >+	trace_gup_get_user_pages_fast(start, nr_pages);
> >+
> >  	/*
> >  	 * local_irq_save() doesn't prevent pagetable teardown, but does
> >  	 * prevent the pagetables from being freed on s390.
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
