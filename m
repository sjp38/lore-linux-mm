Date: Fri, 11 Jul 2008 12:17:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] - GRU virtual -> physical translation
Message-Id: <20080711121736.18687570.akpm@linux-foundation.org>
In-Reply-To: <20080709191439.GA7307@sgi.com>
References: <20080709191439.GA7307@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jul 2008 14:14:39 -0500 Jack Steiner <steiner@sgi.com> wrote:

> Open code the equivalent to follow_page(). This eliminates the
> requirement for an EXPORT of follow_page().

I'd prefer to export follow_page() - copying-n-pasting just to avoid
exporting the darn thing is silly.

> In addition, the code
> is optimized for the specific case that is needed by the GRU and only
> supports architectures supported by the GRU (ia64 & x86_64).

Unless you think that this alone justifies the patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
