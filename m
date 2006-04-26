Date: Wed, 26 Apr 2006 09:55:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Lockless page cache test results
Message-Id: <20060426095511.0cc7a3f9.akpm@osdl.org>
In-Reply-To: <20060426135310.GB5083@suse.de>
References: <20060426135310.GB5083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jens Axboe <axboe@suse.de> wrote:
>
> Running a splice benchmark on a 4-way IPF box, I decided to give the
>  lockless page cache patches from Nick a spin. I've attached the results
>  as a png, it pretty much speaks for itself.

It does.

What does the test do?

In particular, does it cause the kernel to take tree_lock once per page, or
once per batch-of-pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
