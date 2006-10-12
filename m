Date: Wed, 11 Oct 2006 23:43:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][PATCH] EXT3: problem with page fault inside a transaction
Message-Id: <20061011234330.efae4265.akpm@osdl.org>
In-Reply-To: <87mz82vzy1.fsf@sw.ru>
References: <87mz82vzy1.fsf@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dmitriy Monakhov <dmonakhov@openvz.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, devel@openvz.org, ext2-devel@lists.sourceforge.net, Andrey Savochkin <saw@swsoft.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Oct 2006 09:57:26 +0400
Dmitriy Monakhov <dmonakhov@openvz.org> wrote:

> While reading Andrew's generic_file_buffered_write patches i've remembered
> one more EXT3 issue.journal_start() in prepare_write() causes different ranking
> violations if copy_from_user() triggers a page fault. It could cause 
> GFP_FS allocation, re-entering into ext3 code possibly with a different
> superblock and journal, ranking violation of journalling serialization 
> and mmap_sem and page lock and all other kinds of funny consequences.

With the stuff Nick and I are looking at, we won't take pagefaults inside
prepare_write()/commit_write() any more.

> Our customers complain about this issue.

Really?  How often?

What on earth are they doing to trigger this?  writev() without the 2.6.18
writev() bugfix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
