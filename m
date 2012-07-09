Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id BA5336B0093
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:39:26 -0400 (EDT)
Date: Mon, 9 Jul 2012 16:39:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] shmem/tmpfs: three late patches
Message-Id: <20120709163925.4b71bdc2.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils>
References: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 9 Jul 2012 15:35:26 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> Here's three little shmem/tmpfs patches against v3.5-rc6.
> Either the first should go in before v3.5 final, or it should not go
> in at all.  The second and third are independent of it: I'd like them
> in v3.5, but don't have a clinching argument: see what you think.

Thanks, I queued all three for 3.5.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
