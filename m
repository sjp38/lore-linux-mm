Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 1D3086B0068
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 04:20:49 -0400 (EDT)
Message-ID: <1344846039.31459.14.camel@twins>
Subject: Re: [PATCH 0/5] rbtree based interval tree as a prio_tree
 replacement
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 13 Aug 2012 10:20:39 +0200
In-Reply-To: <1344324343-3817-1-git-send-email-walken@google.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Tue, 2012-08-07 at 00:25 -0700, Michel Lespinasse wrote:
> a faster worst-case complexity of O(k+log N) for stabbing queries in a
> well-balanced prio tree, vs O(k*log N) for interval trees (where k=3Dnumb=
er
> of matches, N=3Dnumber of intervals). Now this sounds great, but in pract=
ice
> prio trees don't realize this theorical benefit. First, the additional
> constraint makes them harder to update, so that the kernel implementation
> has to simplify things by balancing them like a radix tree, which is not
> always ideal.=20

Not something spending a great deal of time on, but do you have any idea
what the radix like balancing does the the worst case stabbing
complexity?

Anyway, I like the thing, that prio-tree code always made my head hurt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
