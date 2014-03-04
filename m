Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id DE43F6B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 22:26:17 -0500 (EST)
Received: by mail-ve0-f171.google.com with SMTP id cz12so4834355veb.16
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 19:26:17 -0800 (PST)
Received: from mail-ve0-x235.google.com (mail-ve0-x235.google.com [2607:f8b0:400c:c01::235])
        by mx.google.com with ESMTPS id tx7si5418552vcb.83.2014.03.03.19.26.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 19:26:17 -0800 (PST)
Received: by mail-ve0-f181.google.com with SMTP id oy12so2683587veb.26
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 19:26:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393902810.30648.36.camel@buesod1.americas.hpqcorp.net>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
	<20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
	<1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
	<20140303172348.3f00c9df.akpm@linux-foundation.org>
	<1393900953.30648.32.camel@buesod1.americas.hpqcorp.net>
	<20140303191224.96f93142.akpm@linux-foundation.org>
	<1393902810.30648.36.camel@buesod1.americas.hpqcorp.net>
Date: Mon, 3 Mar 2014 19:26:16 -0800
Message-ID: <CA+55aFwsjHPe4CF009p_L6PyYdP=F2bzi9-Wm5T+O6XPOCS6fg@mail.gmail.com>
Subject: Re: [PATCH v4] mm: per-thread vma caching
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Mar 3, 2014 at 7:13 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>
> Yes, I shortly realized that was silly... but I can say for sure it can
> happen and a quick qemu run confirms it. So I see your point as to
> asking why we need it, so now I'm looking for an explanation in the
> code.

We definitely *do* have users.

One example would be ptrace -> access_process_vm -> __access_remote_vm
-> get_user_pages() -> find_extend_vma() -> find_vma_prev -> find_vma.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
