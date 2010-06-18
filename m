Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C03236B01BF
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 06:21:42 -0400 (EDT)
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1276797878-28893-1-git-send-email-jack@suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 18 Jun 2010 12:21:35 +0200
Message-ID: <1276856495.27822.1697.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Thu, 2010-06-17 at 20:04 +0200, Jan Kara wrote:
> +                       /*
> +                        * Now we can wakeup the writer which frees wc en=
try
> +                        * The barrier is here so that woken task sees th=
e
> +                        * modification of wc.
> +                        */
> +                       smp_wmb();
> +                       __wake_up_locked(&bdi->wb_written_wait, TASK_NORM=
AL);=20

wakeups imply a wmb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
