Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3456B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 11:41:01 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id j5so923848qaq.7
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 08:41:00 -0800 (PST)
Received: from a9-50.smtp-out.amazonses.com (a9-50.smtp-out.amazonses.com. [54.240.9.50])
        by mx.google.com with ESMTP id w9si2748217qad.12.2013.12.13.08.40.59
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 08:41:00 -0800 (PST)
Date: Fri, 13 Dec 2013 16:40:58 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] fs: buffer: move allocation failure loop into the
 allocator
In-Reply-To: <20131213065805.GC8845@lge.com>
Message-ID: <00000142ecd51cc6-b987e565-7b4f-4945-89ba-731f1d1376fb-000000@email.amazonses.com>
References: <1381265890-11333-1-git-send-email-hannes@cmpxchg.org> <1381265890-11333-2-git-send-email-hannes@cmpxchg.org> <20131203165910.54d6b4724a1f3e329af52ac6@linux-foundation.org> <20131204015218.GA19709@lge.com> <20131213065805.GC8845@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Christian Casteyde <casteyde.christian@free.fr>, Pekka Enberg <penberg@kernel.org>

On Fri, 13 Dec 2013, Joonsoo Kim wrote:

> Could you review this patch?
> I think that we should merge it to fix the problem reported by Christian.

I'd be fine with clearing __GFP_NOFAIL but not with using the same flags
as for a higher order alloc. __GFP_NORETRY and __GFP_NOWARN should be left
untouched for the minimal alloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
