Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADE136B025E
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 19:35:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p2so1053425pfk.0
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 16:35:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p9si1884700pgr.284.2017.10.06.16.35.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 16:35:33 -0700 (PDT)
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 27245218F1
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 23:35:33 +0000 (UTC)
Received: by mail-io0-f171.google.com with SMTP id l15so17361164iol.8
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 16:35:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <150728974697.743944.5376694940133890044.stgit@buzz>
References: <150728974697.743944.5376694940133890044.stgit@buzz>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 6 Oct 2017 16:35:12 -0700
Message-ID: <CALCETrWtOcBYdqCY8OgRW8ijNweVcYEvDQ7W63A4m=P=VYdDUw@mail.gmail.com>
Subject: Re: [PATCH] vmalloc: add __alloc_vm_area() for optimizing vmap stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>

On Fri, Oct 6, 2017 at 4:35 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> This same as __vmalloc_node_range() but returns vm_struct rather than
> virtual address. This allows to kill one call of find_vm_area() for
> each task stack allocation for CONFIG_VMAP_STACK=y.
>
> And fix comment about that task holds cache of vm area: this cache used
> for retrieving actual stack pages, freeing is done by vfree_deferred().

Nice!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
