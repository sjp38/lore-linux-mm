Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AF3B18D003B
	for <linux-mm@kvack.org>; Sat, 28 May 2011 20:24:00 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4T0NvYF007841
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 28 May 2011 17:23:58 -0700
Received: by wyf19 with SMTP id 19so2599808wyf.14
        for <linux-mm@kvack.org>; Sat, 28 May 2011 17:23:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1105281634440.14257@sister.anvils>
References: <alpine.LSU.2.00.1105281317090.13319@sister.anvils>
 <1306617270.2497.516.camel@laptop> <alpine.LSU.2.00.1105281437320.13942@sister.anvils>
 <BANLkTinsq-XJGvRVmBa6kRp0RTj9NqGWtA@mail.gmail.com> <alpine.LSU.2.00.1105281634440.14257@sister.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 28 May 2011 17:23:36 -0700
Message-ID: <BANLkTi=9qqiLNuo9qbcLoQtK3CKSPnhn4g@mail.gmail.com>
Subject: Re: [PATCH] mm: fix page_lock_anon_vma leaving mutex locked
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, May 28, 2011 at 5:12 PM, Hugh Dickins <hughd@google.com> wrote:
>
> Though I think I'm arriving at the conclusion that this patch
> is correct as is, despite the doubts that have arisen.

Well, you hopefully saw my second email where I had come to the same conclusion.

So I applied the third patch as well, after all. I think it's at the
very least at least "more correct" than what we have now. Whether that
"page_mapped()" should then be extended to do something else is an
additional thing, and I suspect it would affect the slow-path case
too.

I dunno.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
