Date: Sat, 01 Nov 2008 21:42:03 -0700 (PDT)
Message-Id: <20081101.214203.39646471.davem@davemloft.net>
Subject: Re: 2.6.28-rc2: Unable to handle kernel paging request at
 iov_iter_copy_from_user_atomic
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0811011837110.20211@blonde.site>
References: <a4423d670811010723u3b271fcaxa7d3bdb251a8b246@mail.gmail.com>
	<Pine.LNX.4.64.0811011837110.20211@blonde.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Hugh Dickins <hugh@veritas.com>
Date: Sat, 1 Nov 2008 18:59:24 +0000 (GMT)
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com
Cc: a.beregalov@gmail.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Alexander Beregalov reports oops in __bzero() called from
> copy_from_user_fixup() called from iov_iter_copy_from_user_atomic(),
> when running dbench on tmpfs on sparc64: its __copy_from_user_inatomic
> and __copy_to_user_inatomic should be avoiding, not calling, the fixups.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

This looks great, applied, thanks Hugh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
