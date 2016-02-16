Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9746B0009
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:10:57 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id y8so80371656igp.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:10:57 -0800 (PST)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id d14si3447683ioj.93.2016.02.16.08.10.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 08:10:56 -0800 (PST)
Date: Tue, 16 Feb 2016 10:10:55 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC] Introduce atomic and per-cpu add-max and sub-min
 operations
In-Reply-To: <CALYGNiOpnVSpmL0smMu7xCT78GJ4J02LGeiuZBdVxROEpfrH+Q@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1602161010280.3986@east.gentwo.org>
References: <145544094056.28219.12239469516497703482.stgit@zurg> <20160214165133.GB3965@htj.duckdns.org> <CALYGNiOpnVSpmL0smMu7xCT78GJ4J02LGeiuZBdVxROEpfrH+Q@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, 14 Feb 2016, Konstantin Khlebnikov wrote:

> Yep, they are just abstraction around cmpxchg, as well as a half of atomic
> operations. Probably some architectures could implement this differently.

Ok then use this_cpu_cmpxchg and cmpxchg to implement it instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
