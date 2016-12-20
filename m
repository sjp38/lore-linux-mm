Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9641A6B033D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 13:02:48 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id c20so23991986itb.5
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:02:48 -0800 (PST)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id q77si14024885itb.80.2016.12.20.10.02.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 10:02:47 -0800 (PST)
Received: by mail-it0-x244.google.com with SMTP id c20so14717212itb.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:02:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com> <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
 <156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com> <CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 20 Dec 2016 10:02:46 -0800
Message-ID: <CA+55aFwy6+ya_E8N3DFbrq2XjbDs8LWe=W_qW8awimbxw26bJw@mail.gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Tue, Dec 20, 2016 at 9:31 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> I'll go back and try to see why the page flag contention patch didn't
> get applied.

Ahh, a combination of warring patches by Nick and PeterZ, and worry
about the page flag bits.

Damn. I had mentally marked this whole issue as "solved". But the fact
that we know how to solve it doesn't mean it's done.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
