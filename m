Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3DD66B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 05:21:13 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b132so15513097iti.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 02:21:13 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w10si2250277itf.56.2016.12.16.02.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 02:21:13 -0800 (PST)
Subject: Re: [PATCH 1/4] mm: add new mmgrab() helper
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216095624.GR3107@twins.programming.kicks-ass.net>
 <20161216101915.GC27758@node>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <a2215cbb-36dd-8cc5-9238-d3bca0170ef4@oracle.com>
Date: Fri, 16 Dec 2016 11:20:40 +0100
MIME-Version: 1.0
In-Reply-To: <20161216101915.GC27758@node>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 12/16/2016 11:19 AM, Kirill A. Shutemov wrote:
> On Fri, Dec 16, 2016 at 10:56:24AM +0100, Peter Zijlstra wrote:
>> But I must say mmget() vs mmgrab() is a wee bit confusing.
>
> mm_count vs mm_users is not very clear too. :)
>

I was about to say, I'm not sure it's much better than mmput() vs
mmdrop() or mm_users vs mm_count either, although the way I rationalised
it was the 3 vs 4 letters:

mmget() -- mmgrab()
mmput() -- mmdrop()
   ^^^ 3      ^^^^ 4


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
