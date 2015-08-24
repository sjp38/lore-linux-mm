Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 813526B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 04:39:23 -0400 (EDT)
Received: by lbbpu9 with SMTP id pu9so75275494lbb.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 01:39:22 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id h6si12581099lbz.7.2015.08.24.01.39.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 01:39:21 -0700 (PDT)
Received: by labia3 with SMTP id ia3so8288149lab.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 01:39:20 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
References: <20150823060443.GA9882@gmail.com>
	<20150823064603.14050.qmail@ns.horizon.com>
	<20150823081750.GA28349@gmail.com> <87lhd1wwtz.fsf@rasmusvillemoes.dk>
	<20150824065809.GA13082@gmail.com>
Date: Mon, 24 Aug 2015 10:39:17 +0200
In-Reply-To: <20150824065809.GA13082@gmail.com> (Ingo Molnar's message of
	"Mon, 24 Aug 2015 08:58:09 +0200")
Message-ID: <877fol5bd6.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: George Spelvin <linux@horizon.com>, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

On Mon, Aug 24 2015, Ingo Molnar <mingo@kernel.org> wrote:

>
> Thanks, is the fixed up changelog below better?
>

Yes, though Linus specifically referred to "make test" (but I guess one
could/should consider that part of the build process).

Rasmus


> mm/vmalloc: Cache the vmalloc memory info
>
> Linus reported that for scripting-intense workloads such as the
> Git build, glibc's qsort will read /proc/meminfo for every process
> created (by way of get_phys_pages()), which causes the Git build 
> to generate a surprising amount of kernel overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
