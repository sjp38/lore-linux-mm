Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 33F7C6B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 01:52:53 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so17433661pab.33
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 22:52:52 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id af2si41715679pbc.24.2014.12.03.22.52.50
        for <linux-mm@kvack.org>;
        Wed, 03 Dec 2014 22:52:51 -0800 (PST)
Date: Thu, 4 Dec 2014 15:56:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 6/8] mm/page_owner: keep track of page owners
Message-ID: <20141204065622.GB12141@js1304-P5Q-DELUXE>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1416816926-7756-7-git-send-email-iamjoonsoo.kim@lge.com>
 <547F0EF8.5030402@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <547F0EF8.5030402@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 03, 2014 at 06:54:08PM +0530, Chintan Pandya wrote:
> Hi Kim,

Hello, Chintan.

> 
> This is really useful stuff that you are doing. And the runtime
> allocation for storing page owner stack is a good call.
> 
> Along with that, we also use extended version of the original
> page_owner patch. The extension is, to store stack trace at the time
> of freeing the page. That will indeed eat up space like anything
> (just double of original page_owner) but it helps in debugging some
> crucial issues. Like, illegitimate free, finding leaked pages (if we

Sound really interesting. I hope to see it.

> store their time stamps) etc. The same has been useful in finding
> double-free cases in drivers. But we have never got a chance to
> upstream that. Now that these patches are being discussed again, do
> you think it would be good idea to integrate in the same league of
> patches ?

Good to hear. I think that you can upstream it separately. If you send
the patch, I will review it and help to merge it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
