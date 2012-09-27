Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 7F3E56B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 20:03:54 -0400 (EDT)
Message-ID: <506397E9.1070000@att.net>
Date: Wed, 26 Sep 2012 19:03:53 -0500
From: Daniel Santos <danielfsantos@att.net>
Reply-To: Daniel Santos <daniel.santos@pobox.com>
MIME-Version: 1.0
Subject: Re: Please be aware that __always_inline doesn't mean "always inline"!
References: <50638DCC.5040506@att.net> <20120926165044.46b8f7d6.akpm@linux-foundation.org>
In-Reply-To: <20120926165044.46b8f7d6.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Santos <daniel.santos@pobox.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, torvalds@linux-foundation.org

On 09/26/2012 06:50 PM, Andrew Morton wrote:
> As I mentioned in the other thread, the __always_inline's in fs/namei.c
> (at least) are doing exactly what we want them to do, so some more
> investigation is needed here?
Yes, definitely. When I did some tests on it (to confirm the behavior) a
few months ago, it did behave as advertised. Sounds like this definitely
needs more research. Thanks Andrew.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
