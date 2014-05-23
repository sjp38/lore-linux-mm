Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 08FEF6B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 00:21:55 -0400 (EDT)
Received: by mail-yh0-f45.google.com with SMTP id b6so3803085yha.32
        for <linux-mm@kvack.org>; Thu, 22 May 2014 21:21:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r62si2612638yhc.123.2014.05.22.21.21.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 May 2014 21:21:55 -0700 (PDT)
Message-ID: <537ECCDB.8080009@oracle.com>
Date: Fri, 23 May 2014 00:21:47 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: 3.15.0-rc6: VM_BUG_ON_PAGE(PageTail(page), page)
References: <20140522135828.GA24879@redhat.com>
In-Reply-To: <20140522135828.GA24879@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/22/2014 09:58 AM, Dave Jones wrote:
> Not sure if Sasha has already reported this on -next (It's getting hard
> to keep track of all the VM bugs he's been finding), but I hit this overnight
> on .15-rc6.  First time I've seen this one.

Unfortunately I had to disable transhuge/hugetlb in my testing .config since
the open issues in -next get hit pretty often, and were unfixed for a while
now.

Keeping them enabled just made it impossible to test anything else.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
