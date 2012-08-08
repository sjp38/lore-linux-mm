Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 5306D6B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 10:50:21 -0400 (EDT)
Date: Wed, 8 Aug 2012 09:14:01 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: [PATCH RESEND] mm: Restructure kmem_cache_create() to move debug
 cache integrity checks into a new function
In-Reply-To: <1344272614.2486.40.camel@lorien2>
Message-ID: <alpine.DEB.2.02.1208080913290.7048@greybox.home>
References: <1342221125.17464.8.camel@lorien2> <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com> <1344224494.3053.5.camel@lorien2> <1344266096.2486.17.camel@lorien2> <CAAmzW4Ne5pD90r+6zrrD-BXsjtf5OqaKdWY+2NSGOh1M_sWq4g@mail.gmail.com>
 <1344272614.2486.40.camel@lorien2>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuah.khan@hp.com>
Cc: JoonSoo Kim <js1304@gmail.com>, Pekka Enberg <penberg@kernel.org>, glommer@parallels.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, shuahkhan@gmail.com

On Mon, 6 Aug 2012, Shuah Khan wrote:

> No reason, just something I am used to doing :) inline is a good idea. I
> can fix that easily and send v2 patch.

Leave that to the compiler. There is no performance reason that would
give a benefit from forcing inline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
