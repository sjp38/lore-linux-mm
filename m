Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 21CB76B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 16:56:26 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id hl2so30594860igb.3
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:56:25 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id p3si25778117icw.4.2015.02.24.13.56.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 13:56:25 -0800 (PST)
Received: by mail-ig0-f177.google.com with SMTP id z20so877359igj.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:56:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <9cc2b63100622f5fd17fa5e4adc59233a2b41877.1424779443.git.aquini@redhat.com>
References: <9cc2b63100622f5fd17fa5e4adc59233a2b41877.1424779443.git.aquini@redhat.com>
Date: Tue, 24 Feb 2015 13:56:25 -0800
Message-ID: <CA+55aFz4D9fS1xt7fg0R9Bnngg+_TbNs3fSAaFwoV7eTeLfP5Q@mail.gmail.com>
Subject: Re: [PATCH] mm: readahead: get back a sensible upper limit
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, loberman@redhat.com, Larry Woodman <lwoodman@redhat.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

On Tue, Feb 24, 2015 at 4:58 AM, Rafael Aquini <aquini@redhat.com> wrote:
>
> This patch brings back the old behavior of max_sane_readahead()

Yeah no.

There was a reason that code was killed. No way in hell are we
bringing back the insanities with node memory etc.

Also, we have never actually heard of anything sane that actualyl
depended on this. Last time this came up it was a made-up benchmark,
not an actual real load that cared.

Who can possibly care about this in real life?

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
