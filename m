Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 397846B008A
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 14:17:10 -0400 (EDT)
Received: by wibg7 with SMTP id g7so77750106wib.1
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 11:17:09 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id ib9si13894543wjb.198.2015.03.29.11.17.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 29 Mar 2015 11:17:08 -0700 (PDT)
Message-ID: <5518419E.8010007@nod.at>
Date: Sun, 29 Mar 2015 20:17:02 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 08/11] lib: other kernel glue layer code
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp> <1427202642-1716-9-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1427202642-1716-9-git-send-email-tazaki@sfc.wide.ad.jp>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, linux-arch@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Rusty Russell <rusty@rustcorp.com.au>, Mathieu Lacage <mathieu.lacage@gmail.com>, Christoph Paasch <christoph.paasch@gmail.com>

Am 24.03.2015 um 14:10 schrieb Hajime Tazaki:
> These files are used to provide the same function calls so that other
> network stack code keeps untouched.
> 
> Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
> Signed-off-by: Christoph Paasch <christoph.paasch@gmail.com>
> ---
>  arch/lib/cred.c     |  16 +++
>  arch/lib/dcache.c   |  93 +++++++++++++++
>  arch/lib/filemap.c  |  27 +++++
>  arch/lib/fs.c       | 287 ++++++++++++++++++++++++++++++++++++++++++++
>  arch/lib/glue.c     | 336 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  arch/lib/inode.c    | 146 +++++++++++++++++++++++
>  arch/lib/modules.c  |  36 ++++++
>  arch/lib/pid.c      |  29 +++++
>  arch/lib/print.c    |  56 +++++++++
>  arch/lib/proc.c     | 164 +++++++++++++++++++++++++
>  arch/lib/random.c   |  53 +++++++++
>  arch/lib/security.c |  45 +++++++
>  arch/lib/seq.c      | 122 +++++++++++++++++++
>  arch/lib/splice.c   |  20 ++++
>  arch/lib/super.c    | 210 ++++++++++++++++++++++++++++++++
>  arch/lib/sysfs.c    |  83 +++++++++++++
>  arch/lib/vmscan.c   |  26 ++++
>  17 files changed, 1749 insertions(+)

BTW: Why do you need these stub implementations at all?
If I read your code correctly it is because you're linking against the whole net/ directory.
Let's take register_filesystem() again as example. net/socket.c references it in sock_init().
Maybe it would make sense to split socket.c into two files, net/socket.c and net/sockfs.c.
Such that you could link only net/socket.o.
Of course you'd have to convince networking folks first. :D

By linking selectively objects files from net/ you could get rid of a lot unneeded stubs.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
