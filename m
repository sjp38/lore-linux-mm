Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CE0876B027B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 06:06:50 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100505032033.GA19232@google.com>
References: <20100505032033.GA19232@google.com>
Subject: Re: rwsem: down_read_unfair() proposal
Date: Wed, 05 May 2010 11:06:44 +0100
Message-ID: <22994.1273054004@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: dhowells@redhat.com, Andrew Morton <akpm@google.com>, Linux-MM <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Michel Lespinasse <walken@google.com> wrote:

> and looks like it's doable with the x86 rwsem implementation as well in a
> way that would only involve changes to the rwsem spinlock-protected slow
> paths in lib/rwsem.c .

It's not as easy as it seems.  Once an XADD-based rwsem is contended, you
cannot necessarily tell without looking at the queue whether the rwsem is
currently write-locked or read-locked.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
