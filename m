From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Date: Wed, 19 Nov 2008 17:52:35 +1100
References: <491DAF8E.4080506@quantum.com> <200811191526.00036.nickpiggin@yahoo.com.au>
In-Reply-To: <200811191526.00036.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811191752.35497.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim LaBerge <tim.laberge@quantum.com>
Cc: "Arcangeli, Andrea" <aarcange@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wednesday 19 November 2008 15:25, Nick Piggin wrote:

> For the moment (and previous kernels up to now), I guess you have to
> be careful about fork and get_user_pages, unfortunately.

I'm reminded by someone wishing to remain anonymous that one of
the ways that we can "be careful", is to use MADV_DONTFORK for
ranges that may be under direct IO.

Not a beautiful solution, but it might work.

If you need some sharing of that region between parent and child,
you could alternatively use a shared mapping (eg. MAP_ANONYMOUS |
MAP_SHARED) and avoid the COW issue completely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
