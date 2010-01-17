Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB776B0047
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 10:46:14 -0500 (EST)
Date: Sun, 17 Jan 2010 10:46:05 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 05/12] Export __get_user_pages_fast.
Message-ID: <20100117154605.GB27123@infradead.org>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com> <1262700774-1808-6-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1262700774-1808-6-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 05, 2010 at 04:12:47PM +0200, Gleb Natapov wrote:
> KVM will use it to try and find a page without falling back to slow
> gup. That is why get_user_pages_fast() is not enough.

Btw, it seems like currently is declared unconditionally in linux/mm.h
but only implemented by x86, and you code using it needs ifdefs for
that.  I think you should just introduce a stub that always returns
an error here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
