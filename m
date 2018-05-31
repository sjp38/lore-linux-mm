Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7180E6B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 10:30:30 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c73-v6so20339132qke.2
        for <linux-mm@kvack.org>; Thu, 31 May 2018 07:30:30 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id q7-v6si8328185qvq.265.2018.05.31.07.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 31 May 2018 07:30:29 -0700 (PDT)
Date: Thu, 31 May 2018 14:30:29 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: Can kfree() sleep at runtime?
In-Reply-To: <20180531141452.GC30221@bombadil.infradead.org>
Message-ID: <01000163b69b6b62-6c5ac940-d6c1-419a-9dc9-697908020c53-000000@email.amazonses.com>
References: <30ecafd7-ed61-907b-f924-77fc37dcc753@gmail.com> <20180531140808.GA30221@bombadil.infradead.org> <01000163b68a8026-56fb6a35-040b-4af9-8b73-eb3b4a41c595-000000@email.amazonses.com> <20180531141452.GC30221@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jia-Ju Bai <baijiaju1990@gmail.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 31 May 2018, Matthew Wilcox wrote:

> > Freeing a page in the page allocator also was traditionally not sleeping.
> > That has changed?
>
> No.  "Your bug" being "The bug in your static analysis tool".  It probably
> isn't following the data flow correctly (or deeply enough).

Well ok this is not going to trigger for kfree(), this is x86 specific and
requires CONFIG_DEBUG_PAGEALLOC and a free of a page in a huge page.

Ok that is a very contorted situation but how would a static checker deal
with that?
