Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 139D74403D8
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 22:23:14 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id mw1so50770640igb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 19:23:14 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id p9si35093321igr.62.2016.02.03.19.23.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 03 Feb 2016 19:23:13 -0800 (PST)
Date: Wed, 3 Feb 2016 21:23:11 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 0/3] Speed up SLUB poisoning + disable checks
In-Reply-To: <56B29F77.1010607@redhat.com>
Message-ID: <alpine.DEB.2.20.1602032120060.22468@east.gentwo.org>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org> <20160126070320.GB28254@js1304-P5Q-DELUXE> <56B24B01.30306@redhat.com> <CAGXu5jJK1UhNX7h2YmxxTrCABr8oS=Y2OBLMr4KTxk7LctRaiQ@mail.gmail.com> <56B272B8.2050808@redhat.com>
 <alpine.DEB.2.20.1602031658060.6707@east.gentwo.org> <56B29F77.1010607@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@fedoraproject.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Wed, 3 Feb 2016, Laura Abbott wrote:

> I also notice that __CMPXCHG_DOUBLE is turned off when the debug
> options are turned on. I don't see any details about why. What's
> the reason for turning it off when the debug options are enabled?

Because operations on the object need to be locked out while the debug
code is running. Otherwise concurrent operations from other processors
could lead to weird object states. The object needs to be stable for
debug checks. Poisoning and the related checks need that otherwise you
will get sporadic false positives.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
