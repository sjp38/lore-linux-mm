Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2FF6B00D6
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 12:14:45 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id wo20so4057511obc.11
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 09:14:44 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id bx5si8040300oec.52.2013.12.09.09.14.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 09:14:44 -0800 (PST)
Message-ID: <52A5F83F.4000207@oracle.com>
Date: Mon, 09 Dec 2013 12:05:03 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz>
In-Reply-To: <52A58E8A.3050401@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/09/2013 04:34 AM, Vlastimil Babka wrote:
> Hello, I will look at it, thanks.
> Do you have specific reproduction instructions?

Not really, the fuzzer hit it once and I've been unable to trigger it again. Looking at
the piece of code involved it might have had something to do with hugetlbfs, so I'll crank
up testing on that part.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
