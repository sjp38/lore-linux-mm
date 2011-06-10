Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0026D6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 05:19:43 -0400 (EDT)
Message-ID: <4DF1E1B0.2090907@fusionio.com>
Date: Fri, 10 Jun 2011 11:19:44 +0200
From: Jens Axboe <jaxboe@fusionio.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] tmpfs: clone shmem_file_splice_read
References: <alpine.LSU.2.00.1106091529060.2200@sister.anvils> <alpine.LSU.2.00.1106091531120.2200@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1106091531120.2200@sister.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2011-06-10 00:32, Hugh Dickins wrote:
> Copy __generic_file_splice_read() and generic_file_splice_read()
> from fs/splice.c to shmem_file_splice_read() in mm/shmem.c.  Make
> page_cache_pipe_buf_ops and spd_release_page() accessible to it.

That's a lot of fairly complicated and convoluted code to have
duplicated. Yes, I know I know, it's already largely duplicated from the
normal file read, but still... Really no easy way to share this?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
