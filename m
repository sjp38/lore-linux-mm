Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9A1D8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 17:02:37 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id b16so21929768qtc.22
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 14:02:37 -0800 (PST)
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id b6si2305201qtq.62.2019.01.21.14.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jan 2019 14:02:37 -0800 (PST)
Date: Mon, 21 Jan 2019 22:02:36 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub: use WARN_ON() for some slab errors
In-Reply-To: <1548063490-545-1-git-send-email-miles.chen@mediatek.com>
Message-ID: <01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@email.amazonses.com>
References: <1548063490-545-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org

On Mon, 21 Jan 2019, miles.chen@mediatek.com wrote:

> From: Miles Chen <miles.chen@mediatek.com>
>
> When debugging with slub.c, sometimes we have to trigger a panic in
> order to get the coredump file. To do that, we have to modify slub.c and
> rebuild kernel. To make debugging easier, use WARN_ON() for these slab
> errors so we can dump stack trace by default or set panic_on_warn to
> trigger a panic.

These locations really should dump stack and not terminate. There is
subsequent processing that should be done.

Slub terminates by default. The messages you are modifying are only
enabled if the user specified that special debugging should be one
(typically via a kernel parameter slub_debug).

It does not make sense to terminate the process here.
