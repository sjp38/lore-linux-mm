Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id A839C6B0038
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 23:53:20 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id w8so1379680qac.5
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 20:53:20 -0800 (PST)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id m69si763560qgm.21.2015.01.06.20.53.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 20:53:19 -0800 (PST)
Received: by mail-qg0-f43.google.com with SMTP id z107so450234qgd.2
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 20:53:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54AAB548.3050807@suse.cz>
References: <1418400805-4661-1-git-send-email-vbabka@suse.cz>
	<20141218132619.4e6b349d0aa1744c41f985c7@linux-foundation.org>
	<54AA9E09.7040308@suse.cz>
	<54AAB548.3050807@suse.cz>
Date: Tue, 6 Jan 2015 20:53:19 -0800
Message-ID: <CA+55aFyLWFYzLkE3orkxKsGciq5eUEtcJE5L0uypNZFcW3h2HQ@mail.gmail.com>
Subject: Re: [PATCH V3 0/4] Reducing parameters of alloc_pages* family of functions
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Jan 5, 2015 at 8:01 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> Hm, nope. The !CONFIG_COMPACTION variant of try_to_compact_pages() is static
> inline that returns COMPACT_CONTINUE, which is defined in compaction.h.
> Another solution is to add a "forward" declaration (not actually followed later
> by a full definition) of struct alloc_context into compaction.h. Seems to work
> here, but I'm not sure if such thing is allowed?

We do forward struct declarations quite often (well, _relatively_
often) in order to avoid nasty circular header includes, and sometimes
just to avoid unnecessarily many header includes.

See for example

    git grep '\<struct [a-zA-Z_0-9]*;'

it's not exactly rare.

So it's fine.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
