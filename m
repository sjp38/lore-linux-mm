Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id B0A756B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:42:53 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so128902qaj.35
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 14:42:53 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id u1si2598419qat.30.2014.08.27.14.42.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 14:42:53 -0700 (PDT)
Received: by mail-qc0-f170.google.com with SMTP id r5so79385qcx.15
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 14:42:53 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 27 Aug 2014 14:42:52 -0700
Message-ID: <CAA25o9T+byVZjO5U8krW-hQAnx3jNrvARANtur82b2KFzYpELQ@mail.gmail.com>
Subject: compaction of zspages
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>
Cc: Slava Malyugin <slavamn@google.com>, Sonny Rao <sonnyrao@google.com>

Hello Minchan and others,

I just noticed that the data structures used by zsmalloc have the
potential to tie up memory unnecessarily.  I don't call it "leaking"
because that memory can be reused, but it's not necessarily returned
to the system upon freeing.

I have no idea if this has any impact in practice, but I plan to run a
test in the near future.  Also, I am not sure that doing compaction in
the shrinkers (as planned according to a comment) is the best
approach, because the shrinkers won't be called unless there is
considerable pressure, but the compaction would be more effective when
there is less pressure.

Some more detail here:

https://code.google.com/p/chromium/issues/detail?id=408221

Should I open a bug on some other tracker?

Thank you very much!
Luigi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
