Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA396B00C9
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 04:07:00 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so1351585vbb.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 01:06:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1322038412-29013-1-git-send-email-amwang@redhat.com>
References: <1322038412-29013-1-git-send-email-amwang@redhat.com>
Date: Wed, 23 Nov 2011 11:06:57 +0200
Message-ID: <CAOJsxLGeGyU26AUwzajwFO_o+PEajN6SFfoQqnLf2iOfw+YeZw@mail.gmail.com>
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, Nov 23, 2011 at 10:53 AM, Cong Wang <amwang@redhat.com> wrote:
> Systemd needs tmpfs to support fallocate [1], to be able
> to safely use mmap(), regarding SIGBUS, on files on the
> /dev/shm filesystem. The glibc fallback loop for -ENOSYS
> on fallocate is just ugly.
>
> This patch adds fallocate support to tmpfs, and as we
> already have shmem_truncate_range(), it is also easy to
> add FALLOC_FL_PUNCH_HOLE support too.
>
> 1. http://lkml.org/lkml/2011/10/20/275
>
> V2->V3:
> a) Read i_size directly after holding i_mutex;
> b) Call page_cache_release() too after shmem_getpage();
> c) Undo previous changes when -ENOSPC.
>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Lennart Poettering <lennart@poettering.net>
> Cc: Kay Sievers <kay.sievers@vrfy.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: WANG Cong <amwang@redhat.com>

Looks reasonable to me.

Acked-by: Pekka Enberg <penberg@kernel.org>

Did someone actually test this with systemd?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
