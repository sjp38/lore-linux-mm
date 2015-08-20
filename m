Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id DA4BB6B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 15:23:54 -0400 (EDT)
Received: by iodb91 with SMTP id b91so57610256iod.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 12:23:54 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id x95si3687913ioi.94.2015.08.20.12.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 12:23:54 -0700 (PDT)
Received: by iods203 with SMTP id s203so57915573iod.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 12:23:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440087598-27185-1-git-send-email-klamm@yandex-team.ru>
References: <1440087598-27185-1-git-send-email-klamm@yandex-team.ru>
Date: Thu, 20 Aug 2015 12:23:53 -0700
Message-ID: <CA+55aFz64=vB5vRDj0N0jukWBNnVDd5vf27GL4is6vbYrM17LQ@mail.gmail.com>
Subject: Re: [PATCH] mm/readahead.c: fix regression caused by small readahead limit
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 20, 2015 at 9:19 AM, Roman Gushchin <klamm@yandex-team.ru> wrote:
> +       max_sane = max(MAX_READAHEAD,
> +                      (node_page_state(numa_node_id(), NR_INACTIVE_FILE) +
> +                       node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);

No, we're not re-introducing the idiotic and broken per-node logic.
There was a reason it was killed.

There have been other patches suggested that actually use _valid_
heuristics, this is not one of them.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
