Date: Thu, 12 Oct 2006 01:37:02 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][PATCH] EXT3: problem with page fault inside a transaction
Message-Id: <20061012013702.fe0515ed.akpm@osdl.org>
In-Reply-To: <87lknmgeaz.fsf@sw.ru>
References: <87mz82vzy1.fsf@sw.ru>
	<20061011234330.efae4265.akpm@osdl.org>
	<87lknmgeaz.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dmitriy Monakhov <dmonakhov@sw.ru>
Cc: Dmitriy Monakhov <dmonakhov@openvz.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, ext2-devel@lists.sourceforge.net, Andrey Savochkin <saw@swsoft.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Oct 2006 11:53:56 +0400
Dmitriy Monakhov <dmonakhov@sw.ru> wrote:

> > With the stuff Nick and I are looking at, we won't take pagefaults inside
> > prepare_write()/commit_write() any more.
> I'sorry may be i've missed something, but how cant you prevent this?

Start here: http://lkml.org/lkml/2006/10/11/12

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
