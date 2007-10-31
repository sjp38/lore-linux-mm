From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Date: Wed, 31 Oct 2007 14:26:32 +1100
References: <20071030160401.296770000@chello.nl>
In-Reply-To: <20071030160401.296770000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710311426.33223.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> Hi,
>
> Another posting of the full swap over NFS series.

Hi,

Is it really worth all the added complexity of making swap
over NFS files work, given that you could use a network block
device instead?

Also, have you ensured that page_file_index, page_file_mapping
and page_offset are only ever used on anonymous pages when the
page is locked? (otherwise PageSwapCache could change)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
