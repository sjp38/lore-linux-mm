MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16930.24088.251669.488622@wombat.chubb.wattle.id.au>
Date: Mon, 28 Feb 2005 10:56:08 +1100
From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: Re: [PATCH] Linux-2.6.11-rc5: kernel/sys.c setrlimit() RLIMIT_RSS cleanup
In-Reply-To: <20050227023136.0d1528a7.akpm@osdl.org>
References: <17855236.1109499454066.JavaMail.postfix@mx20.mail.sohu.com>
	<20050227023136.0d1528a7.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: stone_wang@sohu.com, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>>>> "Andrew" == Andrew Morton <akpm@osdl.org> writes:

Andrew> <stone_wang@sohu.com> wrote:
>>  $ ulimit -m 100000 bash: ulimit: max memory size: cannot modify
>> limit: Function not implemented

Andrew> I don't know about this.  The change could cause existing
Andrew> applications and scripts to fail.  Sure, we'll do that
Andrew> sometimes but this doesn't seem important enough. 

What's more, there have been (and still are) out-of-tree patches to
enforce rlimit-RSS in various ways.  There just hasn't been consensus
yet on the best implementation.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
