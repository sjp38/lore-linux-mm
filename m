Date: Wed, 26 Apr 2006 11:46:49 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Lockless page cache test results
Message-Id: <20060426114649.5a0e0dea.akpm@osdl.org>
In-Reply-To: <20060426182323.GI5002@suse.de>
References: <20060426135310.GB5083@suse.de>
	<20060426095511.0cc7a3f9.akpm@osdl.org>
	<20060426174235.GC5002@suse.de>
	<20060426111054.2b4f1736.akpm@osdl.org>
	<20060426182323.GI5002@suse.de>
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
> Are there cases where the lockless page cache performs worse than the
> current one?

Yeah - when human beings try to understand and maintain it.

The usual tradeoffs apply ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
