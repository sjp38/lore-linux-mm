Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 676AB6B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 01:36:24 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so103068144wgy.2
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 22:36:23 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id fq4si21454154wjc.189.2015.04.13.22.36.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Apr 2015 22:36:22 -0700 (PDT)
Received: by wiax7 with SMTP id x7so79997788wia.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 22:36:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1428979956-23667-1-git-send-email-namhyung@kernel.org>
References: <1428979956-23667-1-git-send-email-namhyung@kernel.org>
Date: Tue, 14 Apr 2015 08:36:21 +0300
Message-ID: <CAOJsxLF8gZ2xHRQY7vX45_=hE_9r=HNsoA_3Le5jK==V2WG7Xg@mail.gmail.com>
Subject: Re: [PATCHSET 0/6] perf kmem: Implement page allocation analysis (v7)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Apr 14, 2015 at 5:52 AM, Namhyung Kim <namhyung@kernel.org> wrote:
> Currently perf kmem command only analyzes SLAB memory allocation.  And
> I'd like to introduce page allocation analysis also.  Users can use
>  --slab and/or --page option to select it.  If none of these options
>  are used, it does slab allocation analysis for backward compatibility.

Nice addition!

Acked-by: Pekka Enberg <penberg@kernel.org>

for the whole series.

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
