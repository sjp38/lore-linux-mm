Date: Sun, 27 Feb 2005 02:31:36 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Linux-2.6.11-rc5: kernel/sys.c setrlimit() RLIMIT_RSS
 cleanup
Message-Id: <20050227023136.0d1528a7.akpm@osdl.org>
In-Reply-To: <17855236.1109499454066.JavaMail.postfix@mx20.mail.sohu.com>
References: <17855236.1109499454066.JavaMail.postfix@mx20.mail.sohu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: stone_wang@sohu.com
Cc: riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

<stone_wang@sohu.com> wrote:
>
> $ ulimit  -m 100000
>  bash: ulimit: max memory size: cannot modify limit: Function not implemented

I don't know about this.  The change could cause existing applications and
scripts to fail.  Sure, we'll do that sometimes but this doesn't seem
important enough.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
