Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB0E56B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 15:17:13 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p0PKGWHJ021452
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 12:16:33 -0800
Received: by iwn40 with SMTP id 40so183107iwn.14
        for <linux-mm@kvack.org>; Tue, 25 Jan 2011 12:16:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110125174908.262260777@chello.nl>
References: <20110125173111.720927511@chello.nl> <20110125174908.262260777@chello.nl>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Jan 2011 06:16:08 +1000
Message-ID: <AANLkTikchW7Z6mSgcbt7wn9DWTeEGrKwfMwj1_WjMB5c@mail.gmail.com>
Subject: Re: [PATCH 20/25] mm: Simplify anon_vma refcounts
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 26, 2011 at 3:31 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> This patch changes the anon_vma refcount to be 0 when the object is
> free. It does this by adding 1 ref to being in use in the anon_vma
> structure (iow. the anon_vma->head list is not empty).

Why is this patch part of this series, rather than being an
independent patch before the whole series?

I think this part of the series is the only total no-brainer, ie we
should have done this from the beginning. The preemptability stuff I'm
more nervous about (performance issues? semantic differences?)

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
